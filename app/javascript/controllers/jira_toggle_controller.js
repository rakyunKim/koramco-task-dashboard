import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["manualForm", "jiraSection", "tabManual", "tabJira", "submitBtn"]

  static classes = ["activeTab", "inactiveTab"]

  connect() {
    this.activeTabClasses = "bg-indigo-50 text-indigo-600 border-indigo-200"
    this.inactiveTabClasses = "text-[#64748b] border-[#e2e6ed] hover:border-indigo-300"
  }

  showManual() {
    this.manualFormTarget.classList.remove("hidden")
    if (this.hasJiraSectionTarget) this.jiraSectionTarget.classList.add("hidden")
    this.setTabActive(this.tabManualTarget, this.tabJiraTarget)
  }

  showJira() {
    this.manualFormTarget.classList.add("hidden")
    if (this.hasJiraSectionTarget) this.jiraSectionTarget.classList.remove("hidden")
    this.setTabActive(this.tabJiraTarget, this.tabManualTarget)
  }

  updateCount() {
    if (!this.hasSubmitBtnTarget) return
    const checked = this.jiraSectionTarget.querySelectorAll('input[name="issue_keys[]"]:checked:not(:disabled)')
    this.submitBtnTarget.textContent = checked.length > 0
      ? `${checked.length}개 Jira 티켓 가져오기`
      : "선택한 Jira 티켓 가져오기"
  }

  setTabActive(active, inactive) {
    active.className = `flex-1 h-10 rounded-xl text-sm font-bold transition-all border ${this.activeTabClasses}`
    inactive.className = `flex-1 h-10 rounded-xl text-sm font-bold transition-all border ${this.inactiveTabClasses}`
  }
}
