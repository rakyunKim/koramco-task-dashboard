class WigsController < ApplicationController
  def new
    @wig = Wig.new
  end

  def create
    @wig = Wig.new(wig_params)
    Wig.transaction do
      @wig.save!
      Wig.where.not(id: @wig.id).update_all(active: false)
    end
    redirect_to root_path, notice: "WIG가 설정되었습니다."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def edit
    @wig = Wig.find(params[:id])
  end

  def update
    @wig = Wig.find(params[:id])
    if @wig.update(wig_params)
      redirect_to root_path, notice: "WIG가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Wig.find(params[:id]).destroy
    redirect_to root_path, notice: "WIG가 삭제되었습니다."
  end

  private

  def wig_params
    params.require(:wig).permit(:title, :description, :target_value, :deadline, :active)
  end
end
