class TransformationsController < ApplicationController

  def index
    @transformations = Transformation::ALL_TRANSFORMATIONS
    @pipelines = [] # TransformationPipeline::PIPELINES.reject{ |k, v| @transformations.keys.include?(k)}
  end

  def run
    transformation = "Transformation/#{run_params[:transformation]}_transformation".classify.constantize rescue nil

    if transformation.nil?
      flash[:error] = "Transformation #{run_params[:transformation]} not found!"
      return redirect_to action: :index
    end

    job = Job.create(name: 'TransformationJob', status: :init)
    job.perform_later(transformation.to_s, run_transformation_params(transformation))

    flash[:notice] = "Job started!"
    redirect_to action: :index
  end

  private

  def run_params
    params.require(:run_transformation).permit(:transformation)
  end

  def run_transformation_params(transformation)
    params.require(:run_transformation).permit(transformation::INPUTS.keys)
  end

end
