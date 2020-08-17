class Import::CsvImport < Import
  def run!
    begin
      csv = CSV.read(@file.path, quote_char: '"', headers: true)
      csv.each do |row|
        record = @schema.records.create

        row.each do |key, val|
          next if val.blank? && @schema.attribute_type(key) != 'string' # Skip if empty string and value is not of type string
          stored = record.store_value(key.to_s, val)
          fail "Value #{val} for column #{key} could not be saved!" if stored.nil? && !val.blank?
        end
      end

      return true
    rescue StandardError => e
      return e
    end
  end

  def inputs
    {
      schema: :schema,
      file: :file
    }
  end
end