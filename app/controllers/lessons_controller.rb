class LessonsController < ApplicationController
  before_action :set_lesson, only: [:edit, :show, :update,
                                    :destroy, :quick_show]
  before_action :lesson_owner, only: [:edit, :destroy, :update]
  before_action :authenticate_user!, only: [:create, :new, :create_from_upload,
                                            :edit, :update, :destroy]

  def index
    @lessons = Lesson.order('created_at DESC')
  end

  def show
    @star = Star.find_by(lesson_id: @lesson.id,
                         user_id: current_user.id) if current_user
    @created_documents = Document.where("lesson_id = #{@lesson.id} AND content
        IS NOT NULL").page(params[:page]).per(1)
    @uploaded_documents = Document.where("lesson_id = #{@lesson.id} AND content
        IS NULL").page(params[:page]).per(1)
    @document = @lesson.documents.first
    if current_user && Star.find_by(lesson_id: @lesson.id,
                                    user_id: current_user.id)
      @starred = true
    else
      @starred = false
    end
    @thread = Commontator::Thread.find_by(commontable_id: @lesson.id)
  end

  def quick_show
    @star = Star.new
    if current_user && Star.find_by(lesson_id: @lesson.id,
                                    user_id: current_user.id)
      @starred = true
    else
      @starred = false
    end
    @documents = @lesson.documents
    @uploaded_documents = []
    @created_documents = []
    @documents.each do |d|
      if d.upload.url != '/uploads/original/missing.png'
        @uploaded_documents << d
      else
        @created_documents << d
      end
    end
    render layout: 'quick_show'
  end

  def new
    @lesson = Lesson.new
    @subjects = Subject.all
    @grade_levels = GradeLevel.all
  end

  def create
    @lesson = Lesson.create(lesson_params)
    @subjects = Subject.all
    @grade_levels = GradeLevel.all
    if @lesson.save
      @lesson.user_id = current_user.id
      @lesson.save!
      redirect_to @lesson, notice: 'The lesson has been successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @subjects = Subject.all
    @grade_levels = GradeLevel.all
  end

  def update
    if @lesson.update_attributes(lesson_params)
      redirect_to @lesson, notice: 'The lesson has been successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @lesson.destroy!
    redirect_to user_path(current_user), notice:
        'The document has been successfully deleted.'
  end

  def document_form
    @document = Document.find_by(id: params[:id])
    render layout: false
  end

  private

  def lesson_params
    params.require(:lesson).permit(:upload, :topic, :description, :id, :user_id,
        { subject_ids: [] }, { grade_level_ids: [] })
  end

  def lesson_owner
    redirect_to root_path if @lesson.user_id != current_user.id
  end

  def set_lesson
    @lesson = Lesson.find_by(id: params[:id])
    redirect_to root_path if @lesson.nil?
  end
end
