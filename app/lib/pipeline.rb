class Pipeline

  TRANSFORMATIONS = []

  class << self
    def run_pipeline(pipeline, objs, input)
      raise "#{pipeline} not found!" unless pipeline.is_a?(Class)
      self.new.run!(objs, input)
    end
  end

  attr_reader :transformations

  def initialize
    @transformations = TRANSFORMATIONS.map { |t| "Transformation/#{t}_Transformation".classify.constantize.new }
  end

  def run!(objs, input)
    # Temp storage for results, init with initial input
    results = Array.new(objs.length) { input }

    # Compute Transformation per Transformation
    @transformations.each do |t|
      objs.each_with_index do |obj, i|
        # Give output of last transformation as input
        _, results[i] = t.run!(obj, results[i].second)
      end
    end
  end
end
