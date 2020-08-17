class Transformation
 # Abstract class providing functionality to transform Questions.
 #
 # A transformation takes a question as input and updates/creates a
 # new attribute of this question. Multiple transformations can be
 # chained into a TransformationPipeline.
 #
 # A record within a Transformation should not be saved to the database
 # in order to increase computation speed. Saving to the database is done
 # at the end of a TransformationPipeline.

  ALL_TRANSFORMATIONS = Dir['app/lib/transformation/*_transformation.rb'].map { |f| "Transformation/#{File.basename(f, '.rb')}".classify.constantize }

  class ProceedableError < StandardError
    # Raising this error does not interrupt the TransformationPipeline
  end

  class MissingAttributeError < StandardError; end


  def initialize(params)
    # Parse Input params
    setup_inputs!(params)

    # Specific initialization
    init
  end

  def run!
    begin
      result = transform!
    rescue StandardError => e
      case e
      when ProceedableError
        Rails.logger.error(e)
      else
        raise e
      end
    end
  end

  def self.to_sym
    self.name.underscore.gsub(/\_?transformation\/?/, '').to_sym
  end

  def transform!
    raise 'Missing implementation!'
  end

  def init
    # Do nothing, should be overriden
  end

  def check_attributes
    @inputs.each do |obj_method, trans_method|
      raise MissingAttributeError, "Attribute #{i} is not available on #{@obj}" unless @obj.respond_to?(trans_method)
    end
  end

  def setup_inputs!(params)
    self.class::INPUTS.each do |input, type|
      input = input.to_s
      case type
      when :string
        instance_variable_set "@#{input}", params[input]
      when :collection
        instance_variable_set "@#{input}", Collection.find(params[input])
      when :schema
        instance_variable_set "@#{input}", Schema.find(params[input])
      when :bool
        instance_variable_set "@#{input}", (params[input] == "true" ? true : false)
      end
    end
  end
end
