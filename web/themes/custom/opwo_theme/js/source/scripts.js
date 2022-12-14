/**
 * @file
 * A JavaScript file for the theme.
 *
 * In order for this JavaScript to be loaded on pages, see the instructions in
 * the README.txt next to this file.
 */
// JavaScript should be made compatible with libraries other than jQuery by
// wrapping it with an "anonymous closure". See:
// - https://drupal.org/node/1446420
// - http://www.adequatelygood.com/2010/3/JavaScript-Module-Pattern-In-Depth
(function (Drupal) {
  'use strict';

  // To understand behaviors, see https://www.drupal.org/node/2269515
  Drupal.behaviors.scripts = {
    attach: function (context, settings) {
      /* POLYFILLS */
      // polyfill 'array.from'
      if (!Array.from) {
        Array.from = (function () {
          var symbolIterator;
          try {
            symbolIterator = Symbol.iterator
              ? Symbol.iterator
              : 'Symbol(Symbol.iterator)';
          } catch (e) {
            symbolIterator = 'Symbol(Symbol.iterator)';
          }

          var toStr = Object.prototype.toString;
          var isCallable = function (fn) {
            return (
              typeof fn === 'function' || toStr.call(fn) === '[object Function]'
            );
          };
          var toInteger = function (value) {
            var number = Number(value);
            if (isNaN(number)) return 0;
            if (number === 0 || !isFinite(number)) return number;
            return (number > 0 ? 1 : -1) * Math.floor(Math.abs(number));
          };
          var maxSafeInteger = Math.pow(2, 53) - 1;
          var toLength = function (value) {
            var len = toInteger(value);
            return Math.min(Math.max(len, 0), maxSafeInteger);
          };

          var setGetItemHandler = function setGetItemHandler(
            isIterator,
            items
          ) {
            var iterator = isIterator && items[symbolIterator]();
            return function getItem(k) {
              return isIterator ? iterator.next() : items[k];
            };
          };

          var getArray = function getArray(
            T,
            A,
            len,
            getItem,
            isIterator,
            mapFn
          ) {
            // 16. Let k be 0.
            var k = 0;

            // 17. Repeat, while k < len… or while iterator is done (also steps a - h)
            while (k < len || isIterator) {
              var item = getItem(k);
              var kValue = isIterator ? item.value : item;

              if (isIterator && item.done) {
                return A;
              } else {
                if (mapFn) {
                  A[k] =
                    typeof T === 'undefined'
                      ? mapFn(kValue, k)
                      : mapFn.call(T, kValue, k);
                } else {
                  A[k] = kValue;
                }
              }
              k += 1;
            }

            if (isIterator) {
              throw new TypeError(
                'Array.from: provided arrayLike or iterator has length more then 2 ** 52 - 1'
              );
            } else {
              A.length = len;
            }

            return A;
          };

          // The length property of the from method is 1.
          return function from(arrayLikeOrIterator /*, mapFn, thisArg */) {
            // 1. Let C be the this value.
            var C = this;

            // 2. Let items be ToObject(arrayLikeOrIterator).
            var items = Object(arrayLikeOrIterator);
            var isIterator = isCallable(items[symbolIterator]);

            // 3. ReturnIfAbrupt(items).
            if (arrayLikeOrIterator == null && !isIterator) {
              throw new TypeError(
                'Array.from requires an array-like object or iterator - not null or undefined'
              );
            }

            // 4. If mapfn is undefined, then let mapping be false.
            var mapFn = arguments.length > 1 ? arguments[1] : void undefined;
            var T;
            if (typeof mapFn !== 'undefined') {
              // 5. else
              // 5. a If IsCallable(mapfn) is false, throw a TypeError exception.
              if (!isCallable(mapFn)) {
                throw new TypeError(
                  'Array.from: when provided, the second argument must be a function'
                );
              }

              // 5. b. If thisArg was supplied, let T be thisArg; else let T be undefined.
              if (arguments.length > 2) {
                T = arguments[2];
              }
            }

            // 10. Let lenValue be Get(items, "length").
            // 11. Let len be ToLength(lenValue).
            var len = toLength(items.length);

            // 13. If IsConstructor(C) is true, then
            // 13. a. Let A be the result of calling the [[Construct]] internal method
            // of C with an argument list containing the single item len.
            // 14. a. Else, Let A be ArrayCreate(len).
            var A = isCallable(C) ? Object(new C(len)) : new Array(len);

            return getArray(
              T,
              A,
              len,
              setGetItemHandler(isIterator, items),
              isIterator,
              mapFn
            );
          };
        })();
      }

      // polyfill 'forEach'
      if (window.NodeList && !NodeList.prototype.forEach) {
        NodeList.prototype.forEach = Array.prototype.forEach;
      }

      // polyfill 'matches'
      if (!Element.prototype.matches) {
        Element.prototype.matches =
          Element.prototype.msMatchesSelector ||
          Element.prototype.webkitMatchesSelector;
      }

      // polyfill 'closest'
      if (window.Element && !Element.prototype.closest) {
        Element.prototype.closest = function (s) {
          let el = this;

          do {
            if (Element.prototype.matches.call(el, s)) return el;
            el = el.parentElement || el.parentNode;
          } while (el !== null && el.nodeType === 1);

          return null;
        };
      }

      // IE11 workaround for CSS 'object-fit' support
      const coverImage = (firstLoad) => {
        context.querySelectorAll('.image-cover img').forEach((image) => {
          // only set the background styles on the first load
          if (firstLoad) {
            (image.runtimeStyle || image.style).background = `url("${
              image.src
            }") no-repeat 50%/${
              image.currentStyle ? image.currentStyle['object-fit'] : 'cover'
            }`;
          }

          // adjust width/height on subsequent loads
          image.src = `data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='${image.width}' height='${image.height}'%3E%3C/svg%3E`;
        });
      };

      if ('objectFit' in document.documentElement.style === false) {
        coverImage(true);

        window.onload = function () {
          window.addEventListener('resize', debounce(250, coverImage(false)));
        };
      }

      // image lazy loading JS fallback: if browser doesn't support lazy loading, and supports IntersectionObserver, apply src/srcset attributes as data attrs
      if (
        !('loading' in HTMLImageElement.prototype) &&
        'IntersectionObserver' in window
      ) {
        lazyImages.forEach((lazyImage) => {
          lazyImage.dataset.src = lazyImage.src;
          lazyImage.dataset.srcset = lazyImage.srcset;

          lazyImage.src = null;
          lazyImage.srcset = null;
        });

        let lazyImageObserver = new IntersectionObserver(
          (entries, observer) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                let lazyImage = entry.target;
                lazyImage.src = lazyImage.dataset.src;
                lazyImage.srcset = lazyImage.dataset.srcset;
                lazyImage.classList.remove('img-lazy');
                lazyImageObserver.unobserve(lazyImage);
              }
            });
          }
        );

        lazyImages.forEach((lazyImage) => {
          lazyImageObserver.observe(lazyImage);
        });
      }

      /* END POLYFILLS */

      /* HELPER FUNCTIONS */
      /*!
       * Get all siblings of an element
       * (c) 2021 Chris Ferdinandi, MIT License, https://gomakethings.com
       * @param  {Node}  elem The element
       * @return {Array}      The siblings
       */
      function getSiblings(elem) {
        return Array.from(elem.parentNode.children).filter(function (sibling) {
          return sibling !== elem;
        });
      }

      // debounce function for things like limiting function calls on scroll or window resize
      const debounce = (delay, fn) => {
        let inDebounce = null;

        return (args) => {
          clearTimeout(inDebounce);
          inDebounce = setTimeout(() => fn(args), delay);
        };
      };

      // get all lazy load images
      let lazyImages = [].slice.call(document.querySelectorAll('img.img-lazy'));

      // get all lazy load embeds
      let lazyEmbeds = [].slice.call(
        document.querySelectorAll('iframe[loading]')
      );

      // remove lazy loading from images loaded within view
      const lazyLoad = () => {
        let lazyElements = lazyImages.concat(lazyEmbeds);

        // if no items found, bail early
        if (!lazyElements || !lazyElements.length) {
          return;
        }

        // loop through lazy load images
        lazyElements.forEach((lazyElement) => {
          if (
            lazyElement.getBoundingClientRect().top <= window.innerHeight &&
            lazyElement.getBoundingClientRect().bottom >= 0 &&
            getComputedStyle(lazyElement).display !== 'none'
          ) {
            // remove loading attribute if already within viewport
            lazyElement.removeAttribute('loading');

            // remove img-lazy class if already within viewport
            lazyElement.classList.remove('img-lazy');
          }

          // if image decoding not supported, remove
          if (!('decoding' in HTMLImageElement.prototype)) {
            lazyElement.removeAttribute('decoding');
          }
        });
      };
      lazyLoad();

      // remove 'img-lazy' class from fully loaded images
      lazyImages.forEach((lazyImage) => {
        lazyImage.onload = () => {
          lazyImage.classList.remove('img-lazy');
        };
      });

      // remove 'loading' attribute from fully loaded embeds
      lazyEmbeds.forEach((lazyEmbed) => {
        lazyEmbed.onload = () => {
          lazyEmbed.removeAttribute('loading');
        };
      });

      /* END HELPER FUNCTIONS */

      /* DOCUMENT CLICK */
      // listen for clicks on the document
      document.addEventListener('click', function (e) {
        // prevent mobile menu action on non-mobile screens
        if (window.innerWidth < 1024) {
          // get header, and check if the click was within it
          let menuClose = !document.querySelector('.header').contains(e.target);

          // get current active link - prevent page reload on click, and instead just close the menu
          let currentItem = document.querySelector(
            '.menu_main__link.is-active'
          );
          let currentLink = currentItem
            ? currentItem.contains(e.target)
            : false;

          // close mobile menu if click outside of header, and mobile menu currently active
          if (
            (menuClose || currentLink) &&
            document.body.classList.contains('mobile-menu-open')
          ) {
            mobileMenuToggle();

            e.preventDefault();
          }
        }
      });

      /* END DOCUMENT CLICK */

      /* EXTERNAL LINKS */
      // loop through all external links, and append external link icon SVG
      context
        .querySelectorAll("[href^='http']:not(.sm_link)")
        .forEach((element) => {
          let a = new RegExp('/' + window.location.host + '/');
          if (!a.test(element.href)) {
            element.innerHTML += `<span class="visually-hidden"> (${Drupal.t(
              'external link'
            )})</span><svg viewbox='0 0 16 16' class='external_icon' tabindex='-1' focusable='false' aria-hidden='true'><use xlink:href='#external'></use></svg>`;
            element.target = '_blank';
          }
        });

      /* END EXTERNAL LINKS */

      /* MOBILE MENU */
      // flag for mobile functionality initialized
      let mobileInit = false;

      // function to handle mobile menu functionality
      const mobileMenuToggle = () => {
        // if scroll position of the document > 0, scroll to top
        if (window.scrollY) {
          window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        // toggle active class on toggle element
        document.getElementById('menuToggle').classList.toggle('is-active');

        // toggle flag on body for mobile menu open
        document.body.classList.toggle('mobile-menu-open');
      };

      // function for mobile menu toggle listener
      const menuToggleEvent = () => {
        // toggle mobile menu
        document
          .getElementById('menuToggle')
          .addEventListener('click', function (e) {
            // prevent action on non-mobile screens
            if (window.innerWidth >= 1024) {
              return;
            }

            mobileMenuToggle();

            e.preventDefault();
          });
      };

      // function to load mobile menu functions
      const mobileMenu = () => {
        if (window.innerWidth < 1024 && !mobileInit) {
          menuToggleEvent();

          mobileInit = true;
        }
      };

      // add event listeners for mobile menu functionality
      mobileMenu();

      // listen for window resize events
      window.addEventListener('resize', debounce(250, mobileMenu));

      /* END MOBILE MENU */

      /* ACCORDIONS */
      // init var/holding array for managing open accordion state
      let openAccordions =
        JSON.parse(sessionStorage.getItem('openAccordions')) ?? [];

      const accordionOpened = (e) => {
        // remove this event listener so it only gets triggered once
        e.target.removeEventListener('transitionend', accordionOpened);

        // remove "height" from the element's inline styles, so it can return to its initial value
        e.target.style.height = null;
      };

      // function to manage accordion state on toggle click
      // some of this taken/modified from: https://css-tricks.com/using-css-transitions-auto-dimensions/
      const accordionToggle = (e, savedToggle) => {
        if (e) {
          e.preventDefault();
        }

        let currentToggle = e ? e.target : savedToggle;
        let currentAccordion = currentToggle.nextElementSibling;

        if (currentAccordion.classList.contains('section_toggle__wrapper')) {
          // get height for accordion
          let accordionHeight = currentAccordion.scrollHeight;

          // expand accordion
          if (!currentAccordion.classList.contains('open')) {
            // transition the accordion to the height of its inner content
            currentAccordion.style.height = accordionHeight + 'px';

            // when the next css transition finishes (which we just triggered)
            currentAccordion.addEventListener('transitionend', accordionOpened);
          }
          // collapse accordion
          else {
            currentAccordion.style.height = accordionHeight + 'px';

            // on the next frame (as soon as the previous style change has taken effect), have the element transition to height: 0
            requestAnimationFrame(function () {
              currentAccordion.style.height = 0 + 'px';
            });
          }
        }

        // toggle active state class on toggle button and accordion element
        currentToggle.classList.toggle('toggle-active');
        currentAccordion.classList.toggle('open');

        // add or remove links and buttons from the tab index order (add to tabindex order for active accordions)
        if (currentAccordion.classList.contains('open')) {
          currentAccordion.querySelectorAll('a, button').forEach((element) => {
            element.removeAttribute('tabindex');
          });

          // if not already saved, add current toggle to accordion state management array
          if (!openAccordions.includes(currentToggle.id) && currentToggle.id) {
            openAccordions.push(currentToggle.id);
          }
        } else {
          currentAccordion.querySelectorAll('a, button').forEach((element) => {
            element.tabIndex = -1;
          });

          // remove current toggle from accordion state management array
          openAccordions = openAccordions.filter(
            (value) => value !== currentToggle.id
          );

          if (!openAccordions.length) {
            sessionStorage.removeItem('openAccordions');
          }
        }

        // save accordion state management array to sessionStorage
        if (openAccordions && openAccordions.length) {
          sessionStorage.setItem(
            'openAccordions',
            JSON.stringify(openAccordions)
          );
        }
      };

      // add event listeners for accordion toggle buttons
      Array.from(document.getElementsByClassName('section_toggle')).forEach(
        (element) => {
          // toggle submenu active state on hover and focus
          element.addEventListener('click', accordionToggle);
        }
      );

      // remove links and buttons within the accordion from the tabindex order
      context
        .querySelectorAll(
          '.section_toggle__wrapper a, .section_toggle__wrapper button'
        )
        .forEach((element) => {
          element.tabIndex = -1;
        });

      // loop through saved tabs, and toggle active state
      if (openAccordions.length) {
        Array.from(openAccordions).forEach((element) => {
          // get toggle element, based on saved ID in state management array
          let openAccordion = document.getElementById(element);

          if (openAccordion) {
            // toggle active state for each saved accordion
            accordionToggle(null, document.getElementById(element));
          }
        });
      }

      /* END ACCORDIONS */

      /* SCROLL TOP LINK */
      /*
      let scrollButton = document.getElementById('scrollTop');

      if (scrollButton) {
        const scrollButtonShow = () => {
          if (
            document.body.scrollTop > 20 ||
            document.documentElement.scrollTop > 20
          ) {
            scrollButton.style.opacity = '1';
            scrollButton.style.pointerEvents = 'auto';
          } else {
            scrollButton.style.opacity = '0';
            scrollButton.style.pointerEvents = 'none';
          }
        };

        scrollButtonShow();
        window.addEventListener('scroll', debounce(250, scrollButtonShow));

        const scrollToTop = () => {
          document.body.scrollTop = 0;
          document.documentElement.scrollTop = 0;
        };

        scrollButton.addEventListener('click', scrollToTop);
      }
      */

      /* END SCROLL TOP LINK */

      /* WRAP TABLES */
      // wrap tables within main content to apply overflow styling for mobile support
      const wrapTable = (element) => {
        // skip current table if already wrapped or if current is a nested table
        if (
          element.parentNode.classList.contains('table-wrapper') ||
          element.parentNode.closest('table')
        ) {
          return;
        }

        // if current table has a wrapping element with no class, add table-wrapper class
        if (
          'DIV' === element.parentNode.tagName &&
          !element.parentNode.classList.length
        ) {
          element.parentNode.classList.add('table-wrapper');

          return;
        }

        let tableWrapper = document.createElement('div');
        tableWrapper.classList.add('table-wrapper');

        element.parentNode.insertBefore(tableWrapper, element);
        tableWrapper.appendChild(element);
      };

      context.querySelectorAll('main table').forEach((element) => {
        wrapTable(element);
      });

      /* END WRAP TABLES */
    },
  };
})(Drupal);
