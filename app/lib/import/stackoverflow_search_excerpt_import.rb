class Import::StackoverflowSearchExcerptImport < Import
  def run!
    begin
      # Init
      @url = "https://api.stackexchange.com/2.2/search/excerpts?pagesize=100&order=desc&sort=relevance&q=#{@query}&site=stackoverflow&key=#{Rails.application.credentials.so_app_key}"
      @page = 1

      results = make_request

      while results.kind_of?(Net::HTTPSuccess) && results.body
        json_body = JSON.parse(results.body)
        json_body['items'].each do |item|
          tags, id, title, body, creation_date, item_type = extract_data(item)
          r = @schema.records.create
          r.store_value('tags', tags)
          r.store_value('id', id)
          r.store_value('title', title)
          r.store_value('body', body)
          r.store_value('creation_date', creation_date)
          r.store_value('item_type', item_type)
        end

        wait_for_quota(json_body)

        results = if json_body['has_more'] == true
                    @page += 1
                    make_request
                  else
                    nil
                  end
      end

      return true
    rescue StandardError => e
      pp e
      pp e.backtrace
      return e
    end
  end

  def generate_uri(params)
    URI(@url + "&" + params.to_param)
  end

  def make_request
    uri = generate_uri(page: @page)
    Net::HTTP.get_response(uri)
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
        "name": "SO Questions from Search",
        "attributes": [
          { "name": "id", "type": "int" },
          { "name": "title", "type": "string" },
          { "name": "body", "type": "string" },
          { "name": "creation_date", "type": "date" },
          { "name": "item_type", "type": "string" },
          { "name": "tags", "type": "string", "multiple": true }
          ]
      }
    )
  end

  private

  def wait_for_quota(response)
    return if response['backoff'].nil?
    puts "### Sleep for #{response['backoff']} seconds ####"
    sleep response['backoff']
  end

  def extract_data(item)
    # tags, id, title, question, creation_date, view_count
    tags = item['tags']
    id = item['question_id']
    title = item['title']
    question = item['body']
    creation_date = Time.at(item['creation_date']).to_datetime rescue nil
    item_type = item['item_type']

    [tags, id, title, question, creation_date, item_type]
  end
end