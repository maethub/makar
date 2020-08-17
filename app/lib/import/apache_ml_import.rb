class Import::ApacheMlImport < Import
  def run!
    begin
      # Init
      @from = Date.parse(@from)
      @to = Date.parse(@to)
      @current = @from
      @keywords_array = @keywords.split(',').collect{ |w| w.strip }

      puts "=============================="
      puts "Starting Mailing List Import"
      puts "#{@url} : #{@from} - #{@to}"
      puts "Find #{@min_match} from #{@keywords_array}"
      puts "Search only in Subject: #{@subject_only ? 'Yes' : 'No'}"
      puts "=============================="

      # Loop over dates
      while @current <= @to
        @mbox_url = "#{@url}#{@current.strftime('%Y%m')}.mbox"
        file_path = download_mbox(@mbox_url, sanitize_url_for_filename(@mbox_url))

        if !file_path.nil?
          @mbox = Mbox.open(file_path)
          @mbox.each do |mail|
            from, to, date, subject, content = extract_data(mail)

            # Check content and subject
            next if (subject.nil? && content.nil?) || !content.is_a?(String)

            # Check date
            next if date.nil? || date < @from || date > @to

            # Check keywords
            text = @subject_only ? subject.to_s : "#{subject} #{content}"
            matched = @keywords_array.select{ |s| text.downcase.include?(s) }
            next unless matched.count >= @min_match

            record = @schema.records.create
            record.store_value('mailinglist', @mbox_url)
            record.store_value('from', from)
            record.store_value('to', to)
            record.store_value('date', date)
            record.store_value('subject', subject)
            record.store_value('content', content)
            record.store_value('matched', matched.join(', '))
          end
        end
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
      keywords: :string,
      min_match: :integer,
      subject_only: :bool,
      keep_mbox: :bool,
      schema: [:schema, required: false ]
    }
  end

  def schema_definition
    %Q(
      {
        "name": "Apache ML",
        "attributes": [
          { "name": "mailinglist", "type": "string" },
          { "name": "from", "type": "string" },
          { "name": "to", "type": "string" },
          { "name": "subject", "type": "string" },
          { "name": "content", "type": "string" },
          { "name": "date", "type": "date" },
          { "name": "matched", "type": "string" }
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
    subject = mail.headers[:subject] rescue nil
    content = extract_content(mail).encode('utf-8', 'iso-8859-1')
    [from, to, date, subject, content]
  end

  def extract_content(mail)
    return nil if mail.content.nil? || mail.content.empty?

    content = mail.content
    # Return only available content
    return content.first.content if content.length == 1

    # Try to return content with MIME text/plain
    plain = content.find { |c| c.headers[:content_type]&.mime == "text/plain" }
    return plain.content unless plain.nil?

    # Return first because we don't know better
    content.first.content
  end

  def sanitize_url_for_filename(filename)
    out = filename.dup
    bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', ' ' ]
    bad_chars.each do |bad_char|
      out.gsub!(bad_char, '_')
    end
    out
  end
end