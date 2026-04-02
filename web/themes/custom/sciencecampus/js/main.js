/**
 * @file
 * Science Campus theme JavaScript.
 */

(function (Drupal, once) {
  'use strict';

  Drupal.behaviors.sciencecampusAccordion = {
    attach: function (context) {
      once('sc-accordion', '.accordion__trigger', context).forEach(function (trigger) {
        trigger.addEventListener('click', function () {
          var item = this.closest('.accordion__item');
          var isOpen = item.classList.contains('is-open');

          var accordion = item.closest('.accordion');
          if (accordion) {
            accordion.querySelectorAll('.accordion__item.is-open').forEach(function (openItem) {
              openItem.classList.remove('is-open');
              openItem.querySelector('.accordion__trigger').setAttribute('aria-expanded', 'false');
            });
          }

          if (!isOpen) {
            item.classList.add('is-open');
            this.setAttribute('aria-expanded', 'true');
          }
        });
      });
    }
  };

  Drupal.behaviors.sciencecampusMobileMenu = {
    attach: function (context) {
      once('sc-menu', '.menu-toggle', context).forEach(function (toggle) {
        var nav = document.getElementById('main-nav');
        if (!nav) return;

        toggle.addEventListener('click', function () {
          var isOpen = nav.classList.contains('is-open');
          nav.classList.toggle('is-open');
          this.setAttribute('aria-expanded', String(!isOpen));
        });

        document.addEventListener('click', function (e) {
          if (!nav.contains(e.target) && !toggle.contains(e.target)) {
            nav.classList.remove('is-open');
            toggle.setAttribute('aria-expanded', 'false');
          }
        });
      });
    }
  };

})(Drupal, once);
