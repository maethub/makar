class Export

  ALL_EXPORTS = Dir['app/lib/export/*_export.rb'].map { |f| "Export/#{File.basename(f, '.rb')}".classify.constantize }

  class ProceedableError < StandardError
    # Raising this error does not interrupt the TransformationPipeline
  end

  class MissingAttributeError < StandardError; end


  def initialize(collection, params)
    @collection = collection

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

  def export!
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
      when :attributes
        instance_variable_set "@#{input}", params[input]
      when :attribute
        instance_variable_set "@#{input}", params[input]
      when :bool
        instance_variable_set "@#{input}", (params[input] == "true" ? true : false)
      end
    end
  end
end
