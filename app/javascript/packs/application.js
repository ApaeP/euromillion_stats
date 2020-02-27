require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")

import "bootstrap";

document.addEventListener('turbolinks:load', () => {
    // Do your stuff!
})

if (document.querySelector('#year-tabs')) {
  const nav_btns = document.querySelectorAll('.nav-item')
  nav_btns.forEach((btn) => {
    btn.addEventListener('click', () => {
      document.querySelector('.tab-pane.active').classList.remove('active')
      document.querySelector(`#tab-${btn.dataset.year}`).classList.add('active')
    })
  });
}
