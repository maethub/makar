module QuestionAllowedAttributes

  DEFAULT = {
    show: false,
    export: true,
    type: String,
    html_safe: false,
    show_wrapper: nil,
    virtual: true

  }

  ATTRIBUTES = {
    source: { show: true, virtual: false },
    views: { show: true },
    date: { show: true, virtual: false },
    question_no_tags: {},
    code: {},
    question_stripped: {},
    answer_stripped: {},
    question_sanitized: { show: true, html_safe: true },
    answer_sanitized: { show: true, html_safe: true },
    question_code: { show: true, type: 'Code' },
    answer_code: { show: true, type: 'Code' },
    question_has_code: { show: true },
    answer_has_code: { show: true },
    answer_words: {},
    question_words: {},
    answer_words_freq: { show: true, type: Hash },
    question_words_freq: { show: true, type: Hash }
  }.map{ |k, v| [k, DEFAULT.merge(v)] }.to_h.freeze

  ALLOWED_ATTRIBUTES = ATTRIBUTES.keys.map{ |a| [a, "#{a}=".to_sym] }.flatten.freeze

  ATTRIBUTES_SHOW = ATTRIBUTES.select { |_k, v| v[:show] }.freeze

  ATTRIBUTES_EXPORT = ATTRIBUTES.select { |_k, v| v[:export] }.freeze

end