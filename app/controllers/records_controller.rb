class RecordsController < ApplicationController
  before_action :set_record, only: [:show, :toggle_status, :toggle_collection, :save_record_value]

  def index
    @filter = Filter.find_by_name(params[:load_filter]) if params[:load_filter]
    # @r = Record.active.ransack(params[:q] || @filter&.query)
    @r = ransack_params
    @r.build_grouping unless @r.groupings.any?

    # Save Filter
    if params[:filter] && params[:filter][:save]
      @filter = Filter.find_or_create_by(name: params[:filter][:name])
      @filter.query = params[:q]
      @filter.save!
    end

    @records = ransack_result.paginate(:page => params[:page])
  end

  def show

  end

  def save_record_value
    begin
      @record.store_value(record_value_params[:attr], record_value_params[:data])
    rescue StandardError => e
      error = e.message
    end
    respond_to do |format|
      format.js { render 'card_attribute_form', locals: { attr: record_value_params[:attr], error: error } }
    end
  end

  def toggle_status
    @record.update_attribute(:deactivated, !@record.deactivated)
    respond_to do |format|
      format.js { render 'records/toggle_status', locals: { r: @record } }
    end
  end

  def toggle_collection
    @collection = Collection.find(params[:collection_id])
    if @collection.has_record? @record
      @collection.records.delete(@record)
    else
      @collection.records << @record
    end

    respond_to do |format|
      format.js { render 'records/toggle_collection', locals: { record: @record, collection: @collection } }
    end
  end

  def select_action
    @records = Record.where(id: select_action_params[:record_ids])
    case params[:submit_action]
    when 'add_collection'
      @collection = Collection.find(select_action_params[:collection])
      @collection.records = @records
    when 'remove_collection'
      @collection = Collection.find(select_action_params[:collection])
      @collection.records.destroy(@records)
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def select_action_params
    params.require(:select_action).permit(:collection, record_ids: [])
  end

  def record_value_params
    params.require(:record_value).permit(:data, :attr)
  end

  def ransack_params
    Record.includes(:record_values).ransack(params[:q] || @filter&.query)
  end

  def ransack_result
    @r.result(distinct: true)
  end
end
