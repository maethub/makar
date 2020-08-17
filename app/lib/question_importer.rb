class QuestionImporter

  ATTRIBUTES = {
    source:   { multiple: false, aliases: [:source]},
    title: { mutliple: false, aliases: [:title] },
    question: { mutliple: false, aliases: [:question] },
    answer:   { mutliple: false, aliases: [:answer] },
    url:      { mutliple: false, aliases: [:url, :link] },
    tags:     { multiple: true, split: [',', ';', ' '], aliases: [:tags, :topics] },
    external_id: { multiple: false, aliases: [:id, :url]},
    views:    { multiple: false, aliases: [:views], optional: true },
    date:    { multiple: false, aliases: [:date], optional: true }
  }.freeze

  class << self

    def quora(file_content)
      json = JSON.parse(file_content)
      result = []
      json.each do |q|
        result << import(q, { source: 'quora' })
      end
      result
    end

    def stackexchange(questions)
      result = []
      questions.each do |q|
        result << import(q)
      end
      result
    end

    def stackexchange_data_explorer(csv_file)
      csv_content = CSV.read(csv_file)
      correct_header = 'Id,CreationDate,ViewCount,Title,Body,Tags,Answer'
      header = csv_content.shift
      raise "Format of CSV is not correct: #{header.join(',')} | Should be: #{correct_header}" unless header.join(',') == correct_header
      result = []
      csv_content.each do |line|
        raise "Input is not correct: #{line}" unless line.count == 7
        q = {
          id: line[0],
          date: line[1],
          views: line[2],
          title: line[3],
          question: line[4],
          tags: line[5].gsub(/[<,>]/, ' ').split(/\s+/).reject(&:blank?),
          answer: line[6],
          url: "https://stackoverflow.com/q/#{line[0]}"
        }
        result << import(q, { source: 'stackoverflow' })
      end
      result
    end

    def import(obj, fixed_attributes = {})
      q = Question.new
      ATTRIBUTES.each do |attr, config|
        next unless q.respond_to?("#{attr}=")
        if fixed_attributes[attr]
          # Default value for all imported questions
          q.send("#{attr}=", fixed_attributes[attr])
        elsif config[:multiple]
          attributes = extract_attribute(obj, config[:aliases])
          attributes = split_attribute(attributes, config[:split]) if attributes.is_a?(String)
          q.send("#{attr}=", attributes)
        else
          extracted = extract_attribute(obj, config[:aliases])
          q.send("#{attr}=", extracted) unless config[:optional] && extracted.nil?
        end
      end

      # Return question if valid and saved
      begin
        return [q, nil] if q.save
      rescue StandardError => e
        return [nil, e.message]
      end


      # Return nil if not valid
      [nil, q.errors]
    end

    def extract_attribute(obj, aliases)
      attr = nil
      aliases.each do |a|
        attr = obj.try(a) || obj[a] || obj[a.to_s]
        return attr unless attr.nil?
      end
      return nil
    end

    def split_attribute(attr, split_at)
      return [] if attr.blank?
      split_at.each do |split|
        next unless attr.include?(split)
        return attr.split(split).map(&:strip)
      end
    end
  end
end
