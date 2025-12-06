import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    if (this.activeValue) {
      this.showTab(this.activeValue)
    }
  }

  switch(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    this.showTab(tabId)
  }

  showTab(tabId) {
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabId === tabId) {
        tab.classList.add('active')
      } else {
        tab.classList.remove('active')
      }
    })

    this.panelTargets.forEach(panel => {
      if (panel.id === `tab-${tabId}`) {
        panel.classList.add('show', 'active')
      } else {
        panel.classList.remove('show', 'active')
      }
    })

    this.activeValue = tabId
  }
}
