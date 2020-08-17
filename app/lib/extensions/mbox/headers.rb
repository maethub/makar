module Extensions
  module Mbox
    module Headers
      def []= (name, value)
        name = ::Mbox::Mail::Headers::Name.parse(name)

        if name == :status
          value = ::Mbox::Mail::Headers::Status.parse(value)
        elsif name == :content_type
          value  = ::Mbox::Mail::Headers::ContentType.parse(value)
        end

        if (tmp = @data[name]) && !tmp.is_a?(Array) && !tmp.is_a?(::Mbox::Mail::Headers::ContentType)
          @data[name] = [tmp]
        end

        if @data[name].is_a?(Array)
          @data[name] << value
        else
          @data[name] = value
        end
      end

      def parse (input)
        input = if input.respond_to? :to_io
                  input.to_io
                elsif input.is_a? String
                  StringIO.new(input)
                else
                  raise ArgumentError, 'I do not know what to do.'
                end

        last = nil

        until input.eof? || (line = input.readline).chomp.empty?
          if !line.match(/^\s/)
            next unless matches = line.match(/^([\w\-]+):\s*(.+)$/)

            whole, name, value = matches.to_a

            self[name] = value.strip
            last       = name
          elsif last && self[last]
            if self[last].is_a?(String)
              self[last] << " #{line.strip}"
            elsif self[last].is_a?(Array) && self[last].last.is_a?(String)
              self[last].last << " #{line.strip}"
            elsif self[last].is_a?(::Mbox::Mail::Headers::ContentType)
              #self[last] = ::Mbox::Mail::Headers::ContentType.parse("#{self[last].mime}; #{line}")
              self[last] = ::Mbox::Mail::Headers::ContentType.parse(self[last])
            end
          end
        end

        self
      end
    end
  end
end