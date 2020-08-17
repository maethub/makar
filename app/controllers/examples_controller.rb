class ExamplesController < ApplicationController

  def index; end

  def question_similarity
    @search = params[:search]
    output = QuestionSimilarity.query(@search)
    @result = QuestionSimilarity.get_result! output

    @questions = []
    @result.each do |r|
      @questions << { score: r.first, id: r.last, question: Question.find(r.last) }
    end

    render partial: 'examples/similarity_question_results', locals: { questions: @questions }

  end
end