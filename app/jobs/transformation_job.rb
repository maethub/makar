class TransformationJob < PersistentJob
  queue_as :default


  def perform(job_id, transformation, params)
    @job = Job.find(job_id)
    @job.update_attribute(:status, :running)

    begin
      transformation_class = transformation.constantize
      error(RuntimeError.new("Provided argument is incorrect: #{transformation}")) unless Transformation::ALL_TRANSFORMATIONS.include?(transformation_class)

      @job.output = "Running Transformation #{transformation}...\n"

      t = transformation_class.new(params)
      t.run!

      @job.output += "Finished!"
    rescue StandardError => e
      error(e)
    end

    complete!
  end
end
