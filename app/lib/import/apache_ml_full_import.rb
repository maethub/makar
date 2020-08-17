class Import::ApacheMlFullImport < Import
  def run!
    begin
      # Init
      @from = Date.parse(@from)
      @to = Date.parse(@to)
      @current = @from

      puts "=============================="
      puts "Starting Mailing List Import"
      puts "#{@url} : #{@from} - #{@to}"
      puts "=============================="

      # Loop over dates
      while @current <= @to
        @mbox_url = "#{@url}#{@current.strftime('%Y%m')}.mbox"
        file_path = download_mbox(@mbox_url, sanitize_url_for_filename(@mbox_url))

        if !file_path.nil?
          @mbox = Mbox.open(file_path)
          @mbox.each do |mail|
            from, to, date, message_id, in_reply_to = extract_data(mail)

            # Check date
            next if date.nil? || date < @from || date > @to

            # Next if we only want threads and this is an answer
            next if @thread_only && in_reply_to.present?

            record = @schema.records.create
            record.bulk_store_value('mailinglist', @mbox_url)
            record.bulk_store_value('from', fix_encoding(from))
            record.bulk_store_value('to', fix_encoding(to))
            record.bulk_store_value('date', date)
            record.bulk_store_value('message_id', fix_encoding(message_id))
            record.bulk_store_value('in_reply_to', fix_encoding(in_reply_to))
            record.bulk_store_value('url', "#{@mbox_url}/#{message_id}")

          end
        end
        Record.import_bulk # Save to DB

        File.delete(file_path) unless @keep_mbox
        @current = @current.next_month
      end

      return true
    rescue StandardError => e
      pp e
      pp e.backtrace
      return e
    end
  end

  def inputs
    {
      url: :string,
      from: :date,
      to: :date,
      thread_only: :bool,
      keep_mbox: :bool,
      schema: [:schema, required: false ]
    }
  end

  def schema_definition
    %Q(
      {
        "name": "Apache ML References",
        "attributes": [
          { "name": "mailinglist", "type": "string" },
          { "name": "from", "type": "string" },
          { "name": "to", "type": "string" },
          { "name": "message_id", "type": "string" },
          { "name": "in_reply_to", "type": "string" },
          { "name": "date", "type": "date" },
          { "name": "url", "type": "string" }
          ]
      }
    )
  end

  private

  def download_mbox(url, file_name)
    file_path = "tmp/#{file_name}"

    # Allow reusing stored mbox files
    return file_path if File.exists?(file_path) && File.size(file_path) > 0

    `wget #{url} -O #{file_path}`
    return nil if File.size(file_path) == 0
    file_path
  end

  def extract_data(mail)
    from = mail.headers[:from] rescue nil
    to = mail.headers[:to] rescue nil
    date = Date.parse(mail.headers[:date]) rescue nil
    message_id = mail.headers[:message_id] rescue nil
    in_reply_to = mail.headers[:in_reply_to] rescue nil
    [from, to, date, message_id, in_reply_to]
  end

  def sanitize_url_for_filename(filename)
    out = filename.dup
    bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', ' ' ]
    bad_chars.each do |bad_char|
      out.gsub!(bad_char, '_')
    end
    out
  end

  def fix_encoding(str)
    str = str.join(', ') if str.is_a?(Array)
    return str if str.nil? || str.encoding == Encoding::UTF_8
    encoded = (str.encode('UTF-8', 'ISO-8859-1') rescue nil)
    encoded ||= (str.encode('UTF-8', 'ASCI-8BIT') rescue nil)
    encoded ||= (str.encode('UTF-8', invalid: :replace, undef: :replace) rescue nil)
    encoded
  end
end