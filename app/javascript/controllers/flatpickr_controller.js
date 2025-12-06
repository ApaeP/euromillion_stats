import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["start", "end"]

  connect() {
    this.initFlatpickr()
  }

  disconnect() {
    if (this.startPicker) this.startPicker.destroy()
    if (this.endPicker) this.endPicker.destroy()
  }

  initFlatpickr() {
    const baseOptions = this.baseOptions()

    this.startPicker = flatpickr(this.startTarget, {
      ...baseOptions,
      onChange: (selectedDates) => this.onStartChange(selectedDates)
    })

    this.endPicker = flatpickr(this.endTarget, {
      ...baseOptions,
      onChange: (selectedDates) => this.onEndChange(selectedDates)
    })
  }

  baseOptions() {
    return {
      minDate: "2004-02-13",
      maxDate: new Date(),
      altInput: true,
      mode: "single",
      altFormat: "j F Y",
      dateFormat: "Y-m-d",
      disableMobile: true
    }
  }

  onStartChange(selectedDates) {
    if (selectedDates[0]) {
      this.endTarget.disabled = false
      this.endPicker.config.minDate = selectedDates[0]
      if (!this.endTarget.value || this.endPicker.selectedDates[0] < selectedDates[0]) {
        this.endPicker.jumpToDate(selectedDates[0], true)
        this.endTarget.value = null
      }
      this.endPicker.open()
    } else {
      this.endTarget.disabled = !!this.endTarget.value
      this.endTarget.value = ""
      this.endPicker.config.minDate = null
      this.endPicker.clear()
    }
    this.element.requestSubmit()
  }

  onEndChange(selectedDates) {
    this.startPicker.config.maxDate = selectedDates[0]
    if (!this.startTarget.value || this.startPicker.selectedDates[0] > selectedDates[0]) {
      this.endPicker.jumpToDate(selectedDates[0], true)
    }
    this.element.requestSubmit()
  }
}
