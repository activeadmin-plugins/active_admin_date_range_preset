// Plain script with no imports or exports, so the same file runs as a classic
// script (Sprockets on Active Admin 3) and as an ES module (importmap on
// Active Admin 4). Either way the API is window.ActiveAdminDateRangePreset.
(function () {
  if (window.ActiveAdminDateRangePreset) { return; }

  var defaults = {
    // Manual global time shift, from UTC can be +/- number
    hours_offset: 0,

    // date_to_human_readable = true, then "date_to" consider as including full day without last second
    //  For example Today will be:
    //   true
    //     2015-06-10 - 2015-06-10
    //     2015-06-10 00:00:00 - 2015-06-10 23:59:59
    //   false
    //     2015-06-10 - 2015-06-11
    //     2015-06-10 00:00:00 - 2015-06-11 00:00:00
    date_to_human_readable: false,

    // Display time or not on text inputs: 2015-06-10 vs 2015-06-10 00:00:00
    show_time: false,

    // Array of additional ranges: { title: 'Last 30 days', start: Date, end: Date }
    add_range: []
  };

  var PRESETS = [
    { key: 'today', title: 'Today', range: function (now) {
      var start = day(now, 0);
      return [start, day(start, 1)];
    } },
    { key: 'yesterday', title: 'Yesterday', range: function (now) {
      return [day(now, -1), day(now, 0)];
    } },
    { key: 'week', title: 'This Week', range: function (now) {
      var start = day(now, -daysSinceMonday(now));
      return [start, day(start, 7)];
    } },
    { key: 'month', title: 'This Month', range: function (now) {
      return [new Date(now.getFullYear(), now.getMonth(), 1),
              new Date(now.getFullYear(), now.getMonth() + 1, 1)];
    } },
    { key: 'last_week', title: 'Last Week', range: function (now) {
      var end = day(now, -daysSinceMonday(now));
      return [day(end, -7), end];
    } },
    { key: 'last_month', title: 'Last Month', range: function (now) {
      return [new Date(now.getFullYear(), now.getMonth() - 1, 1),
              new Date(now.getFullYear(), now.getMonth(), 1)];
    } }
  ];

  function day(date, shift) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() + shift);
  }

  // getDay() counts from Sunday, so a plain `- getDay() + 1` lands on
  // tomorrow for Sundays and hands back the week that has not started yet.
  function daysSinceMonday(date) {
    return (date.getDay() + 6) % 7;
  }

  function pad(num) {
    return (num < 10 ? '0' : '') + num;
  }

  // Native date inputs only accept ISO values, so the input's type picks the
  // format; text inputs keep the format the plugin has always written.
  function formatFor(input, date, opts) {
    var ymd = date.getFullYear() + '-' + pad(date.getMonth() + 1) + '-' + pad(date.getDate());
    var hm = pad(date.getHours()) + ':' + pad(date.getMinutes());
    if (input.type === 'date') { return ymd; }
    if (input.type === 'datetime-local') { return ymd + 'T' + hm; }
    return opts.show_time ? ymd + ' ' + hm + ':' + pad(date.getSeconds()) : ymd;
  }

  // "Now" in UTC shifted by hours_offset, as a local Date whose fields hold
  // those wall-clock values.
  function shiftedNow(opts) {
    var now = new Date();
    var utc = new Date(
      now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),
      now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds(),
      now.getUTCMilliseconds()
    );
    return new Date(utc.getTime() + opts.hours_offset * 60 * 60 * 1000);
  }

  function setValue(input, value) {
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }

  function resolveInput(option) {
    if (!option) { return null; }
    return typeof option === 'string' ? document.querySelector(option) : option;
  }

  function fieldInputs(el) {
    return el.querySelectorAll('input:not([type="hidden"]):not([type="submit"])');
  }

  // A wrapper holding both inputs (a date_range filter) uses its first and
  // last. A Formtastic form pair is two wrappers with one input each, so the
  // "to" input lives in the next wrapper.
  function detectInputs(el, options) {
    var inputs = fieldInputs(el);
    var gteq = inputs[0];
    var lteq = inputs[inputs.length - 1];
    var next = el.nextElementSibling;
    if (inputs.length < 2 && next && fieldInputs(next)[0]) {
      lteq = fieldInputs(next)[0];
    }
    return [resolveInput(options.gteq_input) || gteq, resolveInput(options.lteq_input) || lteq];
  }

  var closeOpenMenu = function () {};

  function menuItems(opts) {
    var items = PRESETS.map(function (preset) {
      return { key: preset.key, className: 'btn_' + preset.key, title: preset.title, range: preset.range };
    });
    opts.add_range.forEach(function (range, i) {
      items.push({ key: 'custom_' + i, className: 'btn_date_range_' + i, title: range.title, range: function () {
        return [day(range.start, 0), day(range.end, 0)];
      } });
    });
    return items;
  }

  function openMenu(toggle, opts, fill) {
    closeOpenMenu();

    var items = menuItems(opts);
    var menu = document.createElement('div');
    menu.className = 'block_timerange';
    menu.setAttribute('data-date-range-preset-menu', '');
    menu.setAttribute('role', 'menu');

    items.forEach(function (item) {
      var row = document.createElement('div');
      var button = document.createElement('span');
      button.className = item.className;
      button.setAttribute('data-date-range-preset', item.key);
      button.setAttribute('role', 'menuitem');
      button.tabIndex = 0;
      button.textContent = item.title;
      row.appendChild(button);
      menu.appendChild(row);
    });

    var box = toggle.getBoundingClientRect();
    menu.style.minWidth = box.width + 'px';
    menu.style.top = (box.top + window.scrollY) + 'px';
    menu.style.left = (box.left + window.scrollX) + 'px';

    function choose(target) {
      var button = target.closest('[data-date-range-preset]');
      if (!button) { return; }
      var key = button.getAttribute('data-date-range-preset');
      var item = items.filter(function (it) { return it.key === key; })[0];
      closeOpenMenu();
      fill(item.range(shiftedNow(opts)));
    }

    menu.addEventListener('click', function (e) { choose(e.target); });
    menu.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        choose(e.target);
      } else if (e.key === 'Escape') {
        closeOpenMenu();
        toggle.focus();
      }
    });

    // No stopPropagation: this listener only watches for a click that should
    // close the menu. Active Admin delegates Clear Filters and the has_many
    // buttons from <document>, so swallowing the event would break them.
    function onOutsideClick(e) {
      if (!menu.contains(e.target)) { closeOpenMenu(); }
    }

    closeOpenMenu = function () {
      menu.remove();
      document.body.removeEventListener('click', onOutsideClick);
      toggle.setAttribute('aria-expanded', 'false');
      closeOpenMenu = function () {};
    };

    // Append and bind in the same tick, so the presets are live as soon as
    // the menu is in the document.
    document.body.appendChild(menu);
    document.body.addEventListener('click', onOutsideClick);

    // A link at the right edge of a sidebar would push the menu off screen.
    var overflow = menu.getBoundingClientRect().right - document.documentElement.clientWidth;
    if (overflow > 0) { menu.style.left = Math.max(0, box.left + window.scrollX - overflow) + 'px'; }
    toggle.setAttribute('aria-expanded', 'true');
  }

  function initElement(el, options) {
    // Re-initialising replaces the wiring instead of adding to it, so a host
    // call with options after the auto-init wins. The listener lives on the
    // link, so dropping the old link drops the old wiring with it.
    el.querySelectorAll('[data-date-range-preset-toggle]').forEach(function (link) { link.remove(); });

    var opts = Object.assign({}, defaults, options);
    opts.add_range = opts.add_range || [];

    // The attribute is authoritative in both directions when present.
    var showTime = el.getAttribute('data-show-time');
    if (showTime !== null) { opts.show_time = showTime === 'true'; }

    var inputs = detectInputs(el, options);
    var gteq = inputs[0];
    var lteq = inputs[1];

    var toggle = document.createElement('a');
    toggle.href = '#';
    toggle.className = 'btn_timerange';
    toggle.textContent = 'Set range';
    toggle.setAttribute('data-date-range-preset-toggle', '');
    toggle.setAttribute('aria-haspopup', 'menu');
    toggle.setAttribute('aria-expanded', 'false');

    var label = el.querySelector('label');
    if (label) {
      label.classList.add('datetime_preset_filter_label');
      label.appendChild(toggle);
    } else {
      el.insertBefore(toggle, el.firstChild);
    }

    toggle.addEventListener('click', function (e) {
      e.preventDefault();
      e.stopPropagation();
      openMenu(toggle, opts, function (range) {
        var end = range[1];
        if (opts.date_to_human_readable) { end = new Date(end.getTime() - 1000); }
        if (gteq) { setValue(gteq, formatFor(gteq, range[0], opts)); }
        if (lteq) { setValue(lteq, formatFor(lteq, end, opts)); }
      });
    });
  }

  function toElements(target) {
    if (typeof target === 'string') { return Array.prototype.slice.call(document.querySelectorAll(target)); }
    if (target instanceof Element) { return [target]; }
    return Array.prototype.slice.call(target || []);
  }

  // target: a CSS selector, an Element, or a list of Elements.
  function init(target, options) {
    var elements = toElements(target);
    elements.forEach(function (el) { initElement(el, options || {}); });
    return elements;
  }

  window.ActiveAdminDateRangePreset = { defaults: defaults, init: init };

  function autoInit() {
    init('.datetime_preset_pair');
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', autoInit);
  } else {
    autoInit();
  }
})();
