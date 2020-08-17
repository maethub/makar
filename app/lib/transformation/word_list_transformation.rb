class Transformation::WordListTransformation < Transformation

  DESCRIPTION = 'Removes all punctuation and other artifacts from question_stripped and answer_stripped. Saves the
                resulting list of words in question_words and answer_words.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection
  }.freeze

  URL_REGEX = /[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/=]*)/i
  PUNCTUATION_REGEX = /[.,\/#!$%\^&\*;:{}=\-_`~()\[\]|]/i

  def init
    # Nothing to init
  end

  def transform!
    @collection.records.each do |r|
      input = r.fetch_value(@in_attribute.to_s)
      input = input.gsub(URL_REGEX, '')
      input = input.gsub(PUNCTUATION_REGEX, '')
      r.store_value(@out_attribute, input)
    end
  end
end