class Transformation::ExtractCodeTransformation < Transformation

  DESCRIPTION = 'Finds <code> tags in :in_attribute of all records in :collection and saves :has_code_attribute and :code_attribute on record.'
  INPUTS      = {
                  in_attribute: :string,
                  code_attribute: :string,
                  has_code_attribute: :string,
                  remove_code: :bool,
                  collection: :collection
                }.freeze

  REGEX = /<code(\s+?.*?)*?>(.*?)<\/code>/m

  def transform!
    @collection.records.each do |r|
      data = r.send(@in_attribute).to_s
      match_data = data.scan(REGEX)

      code = match_data.collect(&:second).compact

      has_code = !code.empty?

      r.send(@has_code_attribute + '=', has_code)
      r.send(@code_attribute + '=', has_code ? code : nil)

      if has_code && @remove_code
        r.store_value(@in_attribute.to_s, data.gsub(REGEX, ''))
      end
    end

  end
end