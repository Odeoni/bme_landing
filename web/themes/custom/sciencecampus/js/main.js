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

  // Topic cards (Nobel-díjas page) → smooth-scroll to the accordion section.
  // The Drupal view doesn't render real <a> tags around topic cards, so we
  // delegate clicks at the grid level. Target selector lives on the wrapper
  // (data-scroll-target="#meresi-foglalkozasok"), so the page template
  // controls *where* it scrolls to.
  Drupal.behaviors.sciencecampusTopicScroll = {
    attach: function (context) {
      once('sc-topic-scroll', '[data-scroll-target]', context).forEach(function (grid) {
        var targetSelector = grid.getAttribute('data-scroll-target');
        if (!targetSelector) return;

        grid.addEventListener('click', function (e) {
          var card = e.target.closest('.topic-card');
          if (!card || !grid.contains(card)) return;
          var target = document.querySelector(targetSelector);
          if (!target) return;
          e.preventDefault();
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });

        // Keyboard accessibility: make cards focusable + Enter triggers click.
        grid.querySelectorAll('.topic-card').forEach(function (card) {
          if (!card.hasAttribute('tabindex')) card.setAttribute('tabindex', '0');
          if (!card.hasAttribute('role')) card.setAttribute('role', 'link');
          card.addEventListener('keydown', function (ev) {
            if (ev.key === 'Enter' || ev.key === ' ') {
              ev.preventDefault();
              card.click();
            }
          });
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
