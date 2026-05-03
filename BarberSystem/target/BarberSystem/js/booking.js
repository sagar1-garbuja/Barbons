/**
 * booking.js — Dynamic calendar, time slot fetching, and booking summary.
 * Pure Vanilla JS, no libraries.
 */

document.addEventListener('DOMContentLoaded', function () {

  // ── State ──────────────────────────────────────────────────────────────
  var selectedServiceId    = null;
  var selectedServiceName  = '';
  var selectedServicePrice = 0;
  var selectedDate         = null;   // 'YYYY-MM-DD'
  var selectedTime         = null;   // 'HH:MM'

  var today = new Date();
  today.setHours(0, 0, 0, 0);

  var calYear  = today.getFullYear();
  var calMonth = today.getMonth(); // 0-indexed

  // ── DOM refs ───────────────────────────────────────────────────────────
  var calGrid      = document.getElementById('calGrid');
  var calTitle     = document.getElementById('calTitle');
  var prevMonthBtn = document.getElementById('prevMonth');
  var nextMonthBtn = document.getElementById('nextMonth');
  var timeSlotsWrap= document.getElementById('timeSlots');
  var timeSlotsMsg = document.getElementById('timeSlotsMsg');

  var sumService   = document.getElementById('sumService');
  var sumPrice     = document.getElementById('sumPrice');
  var sumDate      = document.getElementById('sumDate');
  var sumTime      = document.getElementById('sumTime');

  var hiddenServiceId = document.getElementById('hiddenServiceId');
  var hiddenDate      = document.getElementById('hiddenDate');
  var hiddenTime      = document.getElementById('hiddenTime');

  var confirmBtn   = document.getElementById('confirmBtn');

  // ── Service selection ──────────────────────────────────────────────────
  document.querySelectorAll('.service-card-option input[type="radio"]').forEach(function (radio) {
    radio.addEventListener('change', function () {
      selectedServiceId    = this.value;
      selectedServiceName  = this.dataset.name;
      selectedServicePrice = parseFloat(this.dataset.price);
      if (hiddenServiceId) hiddenServiceId.value = selectedServiceId;
      updateSummary();
    });
  });

  // ── Calendar ───────────────────────────────────────────────────────────
  function renderCalendar() {
    var monthNames = ['January','February','March','April','May','June',
                      'July','August','September','October','November','December'];
    calTitle.textContent = monthNames[calMonth] + ' ' + calYear;

    // Disable prev if we're already on current month
    var nowMonth = today.getMonth();
    var nowYear  = today.getFullYear();
    prevMonthBtn.disabled = (calYear === nowYear && calMonth <= nowMonth);

    calGrid.innerHTML = '';

    // Day name headers
    ['Su','Mo','Tu','We','Th','Fr','Sa'].forEach(function (d) {
      var el = document.createElement('div');
      el.className = 'cal-day-name';
      el.textContent = d;
      calGrid.appendChild(el);
    });

    var firstDay = new Date(calYear, calMonth, 1).getDay();
    var daysInMonth = new Date(calYear, calMonth + 1, 0).getDate();

    // Empty cells
    for (var i = 0; i < firstDay; i++) {
      var empty = document.createElement('div');
      empty.className = 'cal-day empty';
      calGrid.appendChild(empty);
    }

    // Day cells
    for (var d = 1; d <= daysInMonth; d++) {
      var cell = document.createElement('div');
      cell.className = 'cal-day';
      cell.textContent = d;

      var cellDate = new Date(calYear, calMonth, d);
      cellDate.setHours(0, 0, 0, 0);

      var dateStr = calYear + '-'
        + String(calMonth + 1).padStart(2, '0') + '-'
        + String(d).padStart(2, '0');

      if (cellDate <= today) {
        cell.classList.add('past');
      } else {
        // Check if this is today (shouldn't be bookable per spec)
        cell.addEventListener('click', function (ds, cd) {
          return function () {
            selectedDate = ds;
            if (hiddenDate) hiddenDate.value = ds;
            // Remove previous selection
            document.querySelectorAll('.cal-day.selected').forEach(function (el) {
              el.classList.remove('selected');
            });
            this.classList.add('selected');
            selectedTime = null;
            if (hiddenTime) hiddenTime.value = '';
            fetchBookedTimes(ds);
            updateSummary();
          };
        }(dateStr, cellDate));
      }

      // Mark today
      if (cellDate.getTime() === today.getTime()) {
        cell.classList.add('today');
      }

      // Re-select if already chosen
      if (dateStr === selectedDate) {
        cell.classList.add('selected');
      }

      calGrid.appendChild(cell);
    }
  }

  prevMonthBtn.addEventListener('click', function () {
    calMonth--;
    if (calMonth < 0) { calMonth = 11; calYear--; }
    renderCalendar();
  });

  nextMonthBtn.addEventListener('click', function () {
    calMonth++;
    if (calMonth > 11) { calMonth = 0; calYear++; }
    renderCalendar();
  });

  renderCalendar();

  // ── Time slots ─────────────────────────────────────────────────────────
  var ALL_SLOTS = [
    '09:00','09:30','10:00','10:30','11:00','11:30',
    '12:00','12:30','13:00','13:30','14:00','14:30',
    '15:00','15:30','16:00','16:30','17:00'
  ];

  function fetchBookedTimes(dateStr) {
    timeSlotsWrap.innerHTML = '<p style="color:var(--muted);font-size:.85rem;">Loading slots...</p>';
    if (timeSlotsMsg) timeSlotsMsg.style.display = 'none';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/appointment?action=getBookedTimes&date=' + dateStr, true);
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        var booked = [];
        try { booked = JSON.parse(xhr.responseText); } catch (e) {}
        renderTimeSlots(booked);
      }
    };
    xhr.send();
  }

  function renderTimeSlots(booked) {
    timeSlotsWrap.innerHTML = '';
    ALL_SLOTS.forEach(function (slot) {
      var div = document.createElement('div');
      div.className = 'time-slot';
      div.textContent = formatTime(slot);

      if (booked.indexOf(slot) !== -1) {
        div.classList.add('booked');
        div.title = 'Fully booked';
      } else {
        div.addEventListener('click', function () {
          document.querySelectorAll('.time-slot.selected').forEach(function (el) {
            el.classList.remove('selected');
          });
          this.classList.add('selected');
          selectedTime = slot;
          if (hiddenTime) hiddenTime.value = slot;
          updateSummary();
        });
      }

      if (slot === selectedTime) div.classList.add('selected');
      timeSlotsWrap.appendChild(div);
    });
  }

  function formatTime(t) {
    var parts = t.split(':');
    var h = parseInt(parts[0]);
    var m = parts[1];
    var ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12 || 12;
    return h + ':' + m + ' ' + ampm;
  }

  // ── Summary update ─────────────────────────────────────────────────────
  function updateSummary() {
    if (sumService) sumService.textContent = selectedServiceName || '—';
    if (sumPrice)   sumPrice.textContent   = selectedServicePrice ? '$' + selectedServicePrice.toFixed(2) : '—';
    if (sumDate)    sumDate.textContent    = selectedDate ? formatDate(selectedDate) : '—';
    if (sumTime)    sumTime.textContent    = selectedTime ? formatTime(selectedTime) : '—';

    // Enable confirm button only when all 3 are selected
    if (confirmBtn) {
      var ready = selectedServiceId && selectedDate && selectedTime;
      confirmBtn.disabled = !ready;
      confirmBtn.style.opacity = ready ? '1' : '0.5';
      confirmBtn.style.cursor  = ready ? 'pointer' : 'not-allowed';
    }
  }

  function formatDate(str) {
    var d = new Date(str + 'T00:00:00');
    return d.toLocaleDateString('en-US', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
  }

  // ── Form submit guard ──────────────────────────────────────────────────
  var bookingForm = document.getElementById('bookingForm');
  if (bookingForm) {
    bookingForm.addEventListener('submit', function (e) {
      if (!selectedServiceId || !selectedDate || !selectedTime) {
        e.preventDefault();
        alert('Please select a service, date, and time before confirming.');
      }
    });
  }

  updateSummary();
});
