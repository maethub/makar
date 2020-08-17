class ImportQuestionsJob < PersistentJob
  queue_as :default

  # Imports questions from uploaded files
  def perform(job_id, method, data)
    @job = Job.find(job_id)
    @job.update_attribute(:status, :running)

    begin
      error(RuntimeError.new("Provided argument is incorrect: #{method}")) unless ['quora', 'stackexchange', 'stackexchange_data_explorer'].include? method
      imported = QuestionImporter.send(method, data)
      failed  = imported.select { |i| i.first.nil? }
      successful  = imported.select { |i| !i.first.nil? }
      log = build_log(method, failed, successful)

      if successful.any?
        ids = successful.collect(&:first).collect(&:id)
        Job.create(name: 'UpdateAttributesJob', status: :init).perform_later(ids)
      end

      @job.output = log
    rescue StandardError => e
      error(e)
    end

    complete!
  end

  private

  def build_log(title, failed, successful)
    log = "Import log: #{title}\n"
    successful ||= []
    successful.each do |i|
      log += "Imported: #{i.first.inspect}\n"
    end
    failed ||= []
    failed.each do |i|
      log += "Error: #{i.second.inspect}\n"
    end

    log = log.html_safe
    log
  end
end
