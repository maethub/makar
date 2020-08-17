class StackexchangeApiImporter
  include HTTParty
  # curl 'https://api.stackexchange.com/2.2/search?key=U4DMV*8nvpm3EOpvf69Rxw((&site=stackoverflow&order=desc&sort=activity&tagged=testing&filter=default' -H 'Cookie: prov=30240f19-9ffe-d285-aa8d-b9d9375a7a01; _ga=GA1.2.1861003014.1537770197; __utmz=27693923.1539088309.2.2.utmcsr=codereview.stackexchange.com|utmccn=(referral)|utmcmd=referral|utmcct=/; acct=t=QYIWXyCs1fmEd50uoGlV7MyfLEaRZbGh&s=ARmlu%2bVdUjn1MKk9SCnlLbxDuQgvg1Y1; __utma=27693923.1861003014.1537770197.1539088309.1541940960.3; __utmc=27693923; __utmt=1; __utmb=27693923.1.10.1541940960' -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36' -H 'Accept: */*' -H 'Referer: https://api.stackexchange.com/docs/search' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed

  base_uri 'https://api.stackexchange.com'

  def initialize(tagged, sort: 'activity', order: 'desc',
                 nottagged: nil, site: 'stackoverflow',
                 page: '1', accepted: 'True')
    @options = { query:
                   {
                     tagged: tagged,
                     sort: sort,
                     order: order,
                     site: site,
                     page: page,
                     accepted: accepted,
                     filter: '!)5cCAfUdmeXaok)oVOaRHpsjSj19'
                   }
    }
    @options[:query][:nottagged] = nottagged if nottagged
  end

  def search
    self.class.get("/2.2/search", @options)
  end

  def search_advanced
    self.class.get("/2.2/search/advanced", @options)
  end

  def get_answer_body(id, site)
    begin
      response = self.class.get("/2.2/answers/#{id}", { query: { site: site, filter: '!bKhRelKXWu0J0*' } })
      parsed = JSON.parse(response.body)
      body = parsed['items']&.first['body']
    rescue StandardError => e
      Rails.logger.debug("#{e.message}\n#{e.backtrace}")
      return nil
    end
    body
  end

  def search_and_parse
    begin
      response = self.class.get("/2.2/search/advanced", @options)
      parsed = JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.debug("#{e.message}\n#{e.backtrace}")
      return nil
    end

    if parsed['error_message']
      raise parsed['error_message']
    end

    questions = []
    parsed['items'].each do |obj|
      q = {}

      q[:answer] = get_answer_body(obj['accepted_answer_id'].to_i, @options[:query][:site])
      next unless q[:answer] # Do not use this question if answer could not be fetched

      q[:id]        = obj['question_id']
      q[:tags]      = obj['tags']
      q[:title]     = obj['title']
      q[:question]  = obj['body']
      q[:url]       = obj['link']
      q[:views]     = obj['view_count']
      q[:date]      = DateTime.strptime(obj['creation_date'].to_s, '%s')
      q[:source]    = @options[:query][:site]

      questions << q
    end

    return questions
  end
end