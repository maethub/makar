class JobsController < ApplicationController

  def index
    @jobs = Job.order(created_at: :desc).all.paginate(:page => params[:page])
  end
end