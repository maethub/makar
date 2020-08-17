class Import::GithubPrImport < Import
  def run!
    begin
      # Init
      @from = Date.parse(@from)
      @to = Date.parse(@to)
      @min_stars_forks = Integer(@min_stars_forks)
      @current = @from
      @keywords_array = @keywords.split(',').collect{ |w| w.strip }

      # Loop over dates
      while @current <= @to
        @events = {}
        threads = []
        # Get all events for date @current
        (0..23).each do |time|
          threads[time] = Thread.new {
            stream_archive("#{@current.strftime('%Y-%m-%d')}-#{time}")
          }
        end

        threads.each { |t| t.join }

        @events.each do |date, events|
          events.each do |e|
            repo_name, title, body, stars, forks, user, date = extract_data(e)

            record = @schema.records.create
            record.store_value('repo_name', repo_name)
            record.store_value('title', title)
            record.store_value('body', body)
            record.store_value('stars', stars)
            record.store_value('forks', forks)
            record.store_value('user', user)
            record.store_value('date', date)
          end
        end

        @current = @current.next_day
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
      from: :date,
      to: :date,
      keywords: :string,
      schema: :schema,
      min_stars_forks: :integer
    }
  end

  def schema_definition
    %Q(
      {
        "name": "Github Issues",
        "attributes": [
          { "name": "repo_name", "type": "string" },
          { "name": "title", "type": "string" },
          { "name": "body", "type": "string" },
          { "name": "user", "type": "string" },
          { "name": "stars", "type": "int" },
          { "name": "forks", "type": "int" },
          { "name": "date", "type": "date" }
          ]
      }
    )
  end

  private

  def stream_archive(date)
    @events[date] = []
    begin
      open("http://data.gharchive.org/#{date}.json.gz") do |gz|
        Zlib::GzipReader.new(gz).each_line do |line|
          json = JSON.parse(line)
          # PullRequests
          next unless json["type"] == "PullRequestReviewCommentEvent" || json["type"] == "PullRequestEvent"
          # Stars / Forks
          next unless [json.dig("payload","pull_request", "base", "repo", "forks_count"), json.dig("payload","pull_request", "base", "repo", "stargazers_count")].compact.max >= @min_stars_forks
          # Keywords
          content = [json.dig("payload","pull_request", "title"), json.dig("payload","pull_request", "body")].compact.join("\n")
          next unless @keywords_array.any? { |key| content.include? key }
          @events[date] << json
        end
      end
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
    # Remove if empty
    @events.delete(date) if @events[date].empty?
    true
  end

  def extract_data(event)
    # repo_name, title, body, stars, forks, user, date
    repo_name = event.dig("payload", "pull_request", "base", "repo", "full_name")
    title = event.dig("payload", "pull_request", "title")
    body = event.dig("payload", "pull_request", "body")
    stars = event.dig("payload", "pull_request", "base", "repo", "stargazers_count")
    forks = event.dig("payload", "pull_request", "base", "repo", "forks_count")
    user = event.dig("payload", "pull_request", "user", "login")
    date = Date.parse(event.dig("payload", "pull_request", "created_at")) rescue nil

    [repo_name, title, body, stars, forks, user, date]
  end
end