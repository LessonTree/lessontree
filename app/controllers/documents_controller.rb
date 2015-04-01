class DocumentsController < ApplicationController
  before_action :set_document, only: [:edit, :show, :update,
        :destroy, :version_history, :document_frame]
  before_action :set_lesson, only: [:show, :destroy]
  before_action :authenticate_user!, only: [:create, :new, :create_from_upload, :edit, :update, :destroy]
  attr_accessor :title, :description

  def index
    @documents = Document.find_by(current_user.id).order("created_at DESC")
  end

  def show
  end

  def new
    @document = Document.new(lesson_id: params[:lesson_id])
  end

  def create
    @document = Document.create(document_params)
    if @document.save
      redirect_to @document.lesson, notice: "The document has been successfully created."
    else
      render action: "new"
    end
  end

  def document_frame
    render layout: false
  end

  def create_from_upload
    @document = Document.create(document_params)
    if @document.save
      redirect_to @document.lesson, notice: "The document has been successfully created."
    else
      render action: "upload_file"
    end
  end

  def edit
  end

  def update
    if @document.update_attributes(document_params)
      redirect_to @document.lesson, notice: "The document has been successfully updated."
    else
      render action: "edit"
    end
  end

  def upload_file
    @document = Document.new
    @lesson_id = params[:lesson_id]
    render layout: false
  end

  def destroy
    @document.destroy!
    redirect_to @lesson, notice: "The document has been successfully deleted."
  end

  def version_history
  end

  private

  def document_params
    params.require(:document).permit(:title, :content, :user_id, :lesson_id, :upload)
  end

  def set_document
    @document = Document.find_by(id: params[:id])
    redirect_to root_path if @document.nil?
  end

  def set_lesson
    @lesson = @document.lesson
  end
end
