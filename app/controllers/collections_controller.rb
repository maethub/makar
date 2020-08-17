class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :export, :update_filter,
                                        :table, :records, :special_export_index, :special_export,
                                        :drop_records, :record]

  def index
    @collections = Collection.all.paginate(:page => params[:page])
  end

  def show
    @records = @collection.records.paginate(page: params[:page], per_page: 30)
  end

  def table
    @records = @collection.records
    @schema = Schema.by_collection(@collection).first
  end

  def records
    @schema = Schema.find(params[:schema_id])
    out = @collection.value_table(@schema.attributes)
    render json: json_decode(out.values)
  end

  def record
    @record = Record.find(params[:record_id])
    @previous = @collection.records.where('id < ?', @record.id).order(id: :desc).limit(1).first
    @next = @collection.records.where('id > ?', @record.id).order(id: :asc).limit(1).first

    render 'records/show'
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      return redirect_to @collection
    else
      return render action: :new
    end
  end

  def edit

  end

  def update
    if @collection.update(collection_params)
      return redirect_to @collection
    else
      return render action: :edit
    end
  end

  def destroy
    @collection.destroy
    redirect_to action: :index
  end

  def drop_records
    @collection.drop_all_records!
    redirect_to @collection
  end

  def export
    format = export_params[:export_format]

    if export_params[:export_attributes].nil?
      flash[:error] = 'Select some attributes to export!'
      return redirect_to action: :show
    end

    data = @collection.export(export_params[:export_attributes])

    case format
    when 'json'
      send_data JSON.pretty_generate(data), filename: "collection_#{@collection.name}_#{DateTime.now.strftime('%y%m%d%H%M%S')}.json"
    when 'csv'
      out = csv_from_hash(data)
      send_data out, filename: "collection_#{@collection.name}_#{DateTime.now.strftime('%y%m%d%H%M%S')}.csv"
    when 'files'
      out = zip_from_hash(data)
      send_data out, filename: "collection_#{@collection.name}_#{DateTime.now.strftime('%y%m%d%H%M%S')}.zip"
    end
  end

  def special_export_index
    @exports = Export::ALL_EXPORTS
  end

  def special_export
    export = "#{special_export_params[:export]}".classify.constantize rescue nil

    if export.nil?
      flash[:error] = "Export #{special_export_params[:export]} not found!"
      return redirect_to collection_path(@collection)
    end
    out, filename = export.new(@collection, special_export_params).export!
    return send_data out, filename: filename
  end

  def update_filter
    @collection.update_filter

    redirect_to action: :show
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :filter_id)
  end

  def export_params
    params.require(:collection_export).permit(:export_format, :export_attributes => [])
  end

  def json_decode(obj)
    case obj
    when String
      parsed = JSON.parse(obj)
      parsed = CGI::escape_html(parsed) if parsed.is_a?(String)
      parsed
    when Array
      obj.map do |e|
        json_decode e
      end
    end
  end

  private

  def csv_from_hash(h)
    col_names = h.first.keys
    out = CSV.generate do |csv|
      csv << col_names
      h.each do |row|
        csv << row.values
      end
    end
    return out
  end

  def zip_from_hash(h)
    require 'zip'
    i = 0
    filename = h.first.keys.join('_')
    stringio = ::Zip::OutputStream.write_buffer do |zio|
      h.each do |row|
        zio.put_next_entry("#{i}_#{filename}.txt")
        i += 1
        zio.write(row.values.join(', '))
      end
    end
    return stringio.string
  end

  private

  def special_export_params
    params.require(:special_export).permit!
  end
end