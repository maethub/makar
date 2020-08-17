class Import::GithubApiImport < Import
  def run!
    begin
      # Init
      @api_client = Octokit::Client.new(per_page: 100)

      page = 1
      results = @api_client.search_issues(query: @query, page: 1)

      while results && results.items.any?
        results.items.each do |r|
          repo_name, title, body, user, date = extract_data(r)
          record = @schema.records.create
          record.store_value('repo_name', repo_name)
          record.store_value('title', title)
          record.store_value('body', body)
          record.store_value('user', user)
          record.store_value('date', date)
        end
        wait_for_quota
        results = more_results? ? @api_client.search_issues(query: @query, page: (page += 1)) : nil
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
      query:  :string,
      schema: [:schema, required: false ]
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
          { "name": "date", "type": "date" }
          ]
      }
    )
  end

  private

  def more_results?
    !@api_client.last_response.rels[:next].nil?
  end

  def wait_for_quota
    return if @api_client.rate_limit.remaining > 0
    puts "### Sleep for #{@api_client.rate_limit.resets_in} seconds ####"
    sleep @api_client.rate_limit.resets_in
  end

  def extract_data(issue)
    # repo_name, title, body, user, date
    repo_name = issue.repository_url&.gsub(/^.*github\.com\/repos\//, '')
    title = issue.title
    body = issue.body
    user = issue.user&.login
    date = issue.created_at&.to_date

    [repo_name, title, body, user, date]
  end
end