require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import "bootstrap";
import "popper.js";
import { FlatpickrBuilder } from '../components/flatpickr';

const initApp = () => {
  new FlatpickrBuilder();

  $('[data-toggle="tooltip"]').tooltip();

  const yearTabs = document.querySelector('#year-tabs');
  if (yearTabs) {
    const navBtns = document.querySelectorAll('.nav-item[data-year]');
    navBtns.forEach((btn) => {
      btn.addEventListener('click', () => {
        document.querySelector('.tab-pane.active')?.classList.remove('active', 'show');
        document.querySelector(`#tab-${btn.dataset.year}`)?.classList.add('active', 'show');
      });
    });
  }
};

document.addEventListener('DOMContentLoaded', initApp);
document.addEventListener('turbolinks:load', initApp);
