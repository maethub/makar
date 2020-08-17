class UpdateAttributesJob < PersistentJob
  queue_as :default

  def perform(job_id, question_ids)
    @job = Job.find(job_id)
    @job.update_attribute(:status, :running)

    begin
      TransformationPipeline.run_pipeline(:count_words, Question.where(id: question_ids))
    rescue StandardError => e
      error(e)
    end


    @job.output = 'Done!'

    complete!
  end
end
