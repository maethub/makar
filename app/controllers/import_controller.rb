class ImportController < ApplicationController

  def index; end

  def quora
    uploaded = params[:quora][:file]

    # Create tempfile
    file = create_tempfile_from_uploaded('quora_upload.csv', uploaded)

    job = Job.create(name: 'ImportQuestionsJob', status: :init)
    job.perform_later('quora', file)

    flash[:notice] = "Import-Job started!"
    redirect_to action: :index
  end

  def stackexchange
    tagged = params[:se][:tagged]

    if tagged.blank?
      flash[:error] = "Please provide a tag to be imported!"
      return redirect_to action: :index
    end

    nottagged = params[:se][:nottagged] unless params[:se][:nottagged].blank?
    page = params[:se][:page] unless params[:se][:page].blank?

    begin
      questions = StackexchangeApiImporter.new(tagged, nottagged: nottagged, page: page).search_and_parse
      imported = QuestionImporter.stackexchange(questions)
    rescue StandardError => e
      flash[:error] = "Import failed: #{e.message}\n #{e.backtrace.truncate(400)}"
      return redirect_to action: :index
    end

    failed  = imported.select { |i| i.first.nil? }
    successful  = imported.select { |i| !i.first.nil? }

    build_log('Stackexchange', failed, successful)
    return render action: :index
  end

  def stackexchange_data
    uploaded = params[:se_data][:file]

    # Create tempfile
    file = create_tempfile_from_uploaded('se_data_upload.csv', uploaded)

    job = Job.create(name: 'ImportQuestionsJob', status: :init)
    job.perform_later('stackexchange_data_explorer', file)

    flash[:notice] = "Import-Job started!"
    redirect_to action: :index
  end

  def plugin
    @import = params[:plugin].constantize.new
    @import.handle_inputs(params[:import_plugin])
    result = @import.run!

    if result.is_a?(StandardError)
      flash[:error] = "#{result.class.name}: #{result.message.truncate(500)}"
    end

    redirect_to action: :index
  end


  private

  def create_tempfile_from_uploaded(name, uploaded)
    path = "tmp/uploads/#{DateTime.now.to_i}_#{name}"
    File.open(path, 'wb') do |f|
      f.write(uploaded.read)
    end
    path
  end

  def build_log(title, failed, successful)
    @log = "Import log: #{title}\n"
    successful ||= []
    successful.each do |i|
      @log += "#{i.first.inspect}\n"
    end
    failed ||= []
    failed.each do |i|
      @log += "Error: #{i.second.inspect.truncate(40)}\n"
    end

    @log = @log.html_safe
  end
end