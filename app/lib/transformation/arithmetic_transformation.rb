class Transformation::ArithmeticTransformation < Transformation

  DESCRIPTION = 'Allows to do simple arithmetic calculations. Values are referenced by {{some_attribute}}.'

  INPUTS      = {
    out_attribute: :string,
    collection: :collection,
    term: :string,
  }.freeze

  def transform!
    variables = @term.scan(/{{([A-Za-z_]+)}}/).flatten
    term = @term.gsub('{{', '@eval_val_').gsub('}}', '')
    @collection.records.each do |r|
      variables.each do |v|
        instance_variable_set("@eval_val_#{v}", r.fetch_value(v))
      end

      result = instance_eval(term) rescue 'NAN'
      r.store_value(@out_attribute, result.to_s)
    end
  end
end