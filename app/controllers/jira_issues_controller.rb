class JiraIssuesController < ApplicationController
  before_action :require_jira_configured

  def index
    fetcher = Jira::IssueFetcher.new
    @projects = fetcher.projects
    issues = fetcher.my_open_issues(project_key: params[:project_key].presence)
    @imported_keys = Task.jira_linked.pluck(:jira_issue_key)
    status_order = ["진행 중", "해야 할 일", "BACKLOG"]
    @grouped_issues = issues.group_by { |i| i[:status] }.sort_by { |status, _| status_order.index(status) || 99 }
    @lead_measures = current_wig&.lead_measures&.current_week || LeadMeasure.none
    @members = Member.ordered
  rescue Jira::Error => e
    redirect_to root_path, alert: "Jira 오류: #{e.message}"
  end

  def import
    fetcher = Jira::IssueFetcher.new
    lead_measure = LeadMeasure.find(params[:lead_measure_id])
    member = Member.find(params[:member_id])
    issue_keys = params[:issue_keys] || []

    if issue_keys.empty?
      return redirect_to jira_issues_path, alert: "가져올 티켓을 선택해주세요."
    end

    issues = issue_keys.map { |key| fetcher.find(key) }
    imported = Jira::ImportService.new.import(
      issues: issues,
      lead_measure: lead_measure,
      member: member
    )

    redirect_to root_path, notice: "#{imported.size}개 Jira 티켓을 가져왔습니다."
  rescue Jira::Error => e
    redirect_to jira_issues_path, alert: "가져오기 실패: #{e.message}"
  end

  private

  def require_jira_configured
    unless JiraSetting.configured?
      redirect_to edit_jira_setting_path, alert: "먼저 Jira 연동 설정을 완료해주세요."
    end
  end

  def current_wig
    Wig.where(active: true).first
  end
end
