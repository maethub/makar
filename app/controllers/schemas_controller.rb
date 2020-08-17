class SchemasController < ApplicationController
  before_action :set_schema, only: [:show, :edit, :update, :destroy]

  def index
    @schemas = Schema.all
  end

  def show
  end

  def new
    @schema = Schema.new
  end

  def create
    @schema = Schema.new(schema_params)
    if @schema.save
      return redirect_to @schema
    else
      return render action: :new
    end
  end

  def edit

  end

  def update
    if @schema.update(schema_params)
      return redirect_to @schema
    else
      return render action: :edit
    end
  end

  def destroy
    @schema.destroy
    redirect_to action: :index
  end

  private

  def set_schema
    @schema = Schema.find(params[:id])
  end

  def schema_params
    params.require(:schema).permit(:name, :schema)
  end
end