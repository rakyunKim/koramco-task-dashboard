class MembersController < ApplicationController
  def index
    @members = Member.ordered.includes(:tasks)
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      redirect_to members_path, notice: "멤버가 추가되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if @member.update(member_params)
      redirect_to members_path, notice: "멤버 정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Member.find(params[:id]).destroy
    redirect_to members_path, notice: "멤버가 삭제되었습니다."
  end

  private

  def member_params
    params.require(:member).permit(:name)
  end
end
