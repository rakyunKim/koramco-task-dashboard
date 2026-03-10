class JiraSettingsController < ApplicationController
  def edit
    @jira_setting = JiraSetting.current || JiraSetting.new
  end

  def update
    @jira_setting = JiraSetting.current || JiraSetting.new

    if @jira_setting.update(jira_setting_params)
      redirect_to edit_jira_setting_path, notice: "Jira 설정이 저장되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def test_connection
    setting = JiraSetting.current
    if setting&.connection_valid?
      redirect_to edit_jira_setting_path, notice: "Jira 연결 성공!"
    else
      redirect_to edit_jira_setting_path, alert: "Jira 연결 실패. 설정을 확인해주세요."
    end
  end

  def destroy
    JiraSetting.current&.destroy
    redirect_to edit_jira_setting_path, notice: "Jira 연동이 해제되었습니다."
  end

  private

  def jira_setting_params
    params.require(:jira_setting).permit(:site_url, :email, :api_token)
  end
end
