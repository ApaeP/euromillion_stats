import flatpickr from "flatpickr"

export class FlatpickrBuilder {
  constructor() {
    this.form = document.querySelector(".flatpickr-form");
    if (!this.form) return;

    this.startInput = this.form.querySelector(".flatpickr-start-input");
    this.endInput = this.form.querySelector(".flatpickr-end-input");
    this.initFlatpickr();
  }

  initFlatpickr() {
    this.setOptions()
    this.setStartInputOptions()
    this.setEndInputOptions()
    this.startDateFlatpickr = flatpickr(this.startInput, this.startInputOptions)
    this.endDateFlatpickr = flatpickr(this.endInput, this.endInputOptions)
  };

  setOptions() {
    this.options = {
      minDate: "2004-02-13",
      maxDate: new Date(),
      altInput: true,
      mode: "single",
      altFormat: "F j, Y",
      dateFormat: "Y-m-d",
      title: "Select Date",
      name: "date",
      disableMobile: true,
      // disable: [
      //   function (date) {
      //     return date.getDay() === 0 ||
      //            date.getDay() === 1 ||
      //            date.getDay() === 3 ||
      //            date.getDay() === 4 ||
      //            date.getDay() === 6;
      //   },
      // ],
    };
  }

  setStartInputOptions() {
    this.startInputOptions = {
      ...this.options,
      onChange: (selectedDates, _dateStr, _instance) => {
        if (selectedDates[0]) {
          this.endInput.disabled = false
          this.endDateFlatpickr.config.minDate = selectedDates[0]
          if (!this.endInput.value || this.endDateFlatpickr.selectedDates[0] < selectedDates[0]) {
            this.endDateFlatpickr.jumpToDate(selectedDates[0], true)
            this.endInput.value = null
          }
          this.endDateFlatpickr.open()
        } else if (!selectedDates[0]) {
          this.endInput.disabled = !!this.endInput.value
          this.endInput.value = ""
          this.endDateFlatpickr.config.minDate = null
          this.endDateFlatpickr.clear()
        }
        this.form.submit()
      }
    }
  }

  setEndInputOptions() {
    console.log(this.options);
    this.endInputOptions = {
      ...this.options,
      onChange: (selectedDates, _dateStr, _instance) => {
        this.startDateFlatpickr.config.maxDate = selectedDates[0]
        if (!this.startInput.value || this.startDateFlatpickr.selectedDates[0] > selectedDates[0]) {
          this.endDateFlatpickr.jumpToDate(selectedDates[0], true)
          // this.endInput.value = null
        }
        this.form.submit()
      }
    }
  }
}
