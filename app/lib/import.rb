class Import

  def run!
    raise 'implement me!'
  end

  def inputs
    raise 'implement me!'
  end

  def schema_definition
    raise 'Schema parameter not given and no default Schema available!'
  end

  def handle_inputs(params)
    inputs.each do |key, val|
      case (val.is_a?(Array) ? val.first : val)
      when :schema
        instance_variable_set "@#{key}", Schema.find_by_id(params[key])
        if @schema.nil?
          # Try to init schema
          @schema = Schema.create(name: "#{self.class.name}_#{DateTime.now}", schema: schema_definition)
        end
      when :integer
        instance_variable_set "@#{key}", (Integer(params[key]) rescue 1)
      when :bool
        instance_variable_set "@#{key}", (params[key] == "true" ? true : false)
      else
        instance_variable_set "@#{key}", params[key]
      end
    end
  end
end