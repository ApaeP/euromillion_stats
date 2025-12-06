import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

const French = {
  weekdays: {
    shorthand: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
    longhand: ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
  },
  months: {
    shorthand: ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sep", "Oct", "Nov", "Déc"],
    longhand: ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
  },
  firstDayOfWeek: 1,
  ordinal: () => "er",
  rangeSeparator: " au ",
  weekAbbreviation: "Sem",
  scrollTitle: "Défiler pour augmenter",
  toggleTitle: "Cliquer pour basculer"
}

export default class extends Controller {
  static targets = ["start", "end"]

  connect() {
    this.locale = document.documentElement.lang || 'fr'
    this.initFlatpickr()
  }

  disconnect() {
    if (this.startPicker) this.startPicker.destroy()
    if (this.endPicker) this.endPicker.destroy()
  }

  initFlatpickr() {
    const baseOptions = this.baseOptions()

    if (this.hasStartTarget) {
      this.startPicker = flatpickr(this.startTarget, {
        ...baseOptions,
        onChange: (selectedDates) => this.onStartChange(selectedDates)
      })
    }

    if (this.hasEndTarget) {
      this.endPicker = flatpickr(this.endTarget, {
        ...baseOptions,
        onChange: (selectedDates) => this.onEndChange(selectedDates)
      })
    }
  }

  baseOptions() {
    const isFrench = this.locale === 'fr'
    return {
      minDate: "2004-02-13",
      maxDate: new Date(),
      altInput: true,
      mode: "single",
      altFormat: isFrench ? "j F Y" : "F j, Y",
      dateFormat: "Y-m-d",
      disableMobile: true,
      locale: isFrench ? French : undefined
    }
  }

  onStartChange(selectedDates) {
    if (selectedDates[0]) {
      if (this.hasEndTarget) {
        this.endTarget.disabled = false
        this.endPicker.config.minDate = selectedDates[0]
        if (!this.endTarget.value || this.endPicker.selectedDates[0] < selectedDates[0]) {
          this.endPicker.jumpToDate(selectedDates[0], true)
          this.endTarget.value = null
        }
        this.endPicker.open()
      }
    } else if (this.hasEndTarget) {
      this.endTarget.disabled = !!this.endTarget.value
      this.endTarget.value = ""
      this.endPicker.config.minDate = null
      this.endPicker.clear()
    }
    this.submitForm()
  }

  onEndChange(selectedDates) {
    if (this.hasStartTarget) {
      this.startPicker.config.maxDate = selectedDates[0]
      if (!this.startTarget.value || this.startPicker.selectedDates[0] > selectedDates[0]) {
        this.endPicker.jumpToDate(selectedDates[0], true)
      }
    }
    this.submitForm()
  }

  submitForm() {
    this.element.requestSubmit()
  }
}
