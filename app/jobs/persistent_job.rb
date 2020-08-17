class PersistentJob < ApplicationJob

  def error(err)
    @job.status = :failed
    @job.error = err.message
    @job.save!

    raise err
  end

  def complete!
    @job.status = :completed
    @job.save!
  end
end