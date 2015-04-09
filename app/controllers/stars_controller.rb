class StarsController < ApplicationController

  def new
    @star = Star.new
  end

  def show
    @star = Star.create
    @star.lesson_id = params[:id]
    @star.user_id = current_user.id
    @star.save!
    redirect_to lesson_path
  end

  def create
    @star = Star.create
    @star.lesson_id = params[:lesson_id]
    @star.user_id = current_user.id
    @star.save!
    redirect_to lesson_path
  end

  def update
    @star = Star.find(params[:id])
    if @star.update_attributes(star_params)
      redirect_to @star, notice: "The star has been successfully updated."
    else
      render action: "edit"
    end
  end

  def destroy
    star = Star.find_by(lesson_id: params[:lesson_id], user_id: current_user.id)
    Star.destroy(star.id)
  end

private

  def star_params
    params.require(:star).permit(:upload, :topic, :description, :id, :user_id, :lesson_id)
  end

end
