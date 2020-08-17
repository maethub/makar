class Export::MalletExport < Export

  DESCRIPTION = 'Export data for usage in the Mallet LDA Tool'

  INPUTS      = {
    data: :attribute,
    metadata: :attributes
  }.freeze

  def export!
    data = @collection.export(@data, true)
    metadata = @collection.export(@metadata, true)

    return mallet_zip_from_hash(data, metadata), 'mallet.zip'
  end

  def mallet_zip_from_hash(data, metadata)
    require 'zip'
    stringio = ::Zip::OutputStream.write_buffer do |zio|
      data.each do |row|
        zio.put_next_entry("input_dir/#{row.values.first}")
        zio.write(row.values.second.to_s)
      end

      # key_to_dismiss = h.first.keys.second
      zio.put_next_entry("metadata.csv")
      zio.write(csv_from_hash(metadata))
    end
    return stringio.string
  end

  def csv_from_hash(h)
    col_names = h.first.keys
    out = CSV.generate do |csv|
      csv << col_names
      h.each do |row|
        csv << row.values
      end
    end
    return out
  end
end