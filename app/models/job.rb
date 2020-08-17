class Job < ApplicationRecord
  enum status: { init: 'init', running: 'running', completed: 'completed', failed: 'failed' }

  def perform_later(*args)
    self.parameters = args.inspect
    self.save!
    self.name.constantize.perform_later(self.id, *args)
  end

end