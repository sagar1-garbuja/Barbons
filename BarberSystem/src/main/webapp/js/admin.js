/**
 * admin.js — Admin panel interactions.
 * Handles: inline edit toggles, confirm dialogs, table filtering, alert auto-dismiss.
 */

// Wait until the whole page has loaded before running any code
document.addEventListener('DOMContentLoaded', function () {

  // ── Inline edit toggle ────────────────────────────────────────────────
  // Find every "Edit" button on the page and attach a click listener
  document.querySelectorAll('.edit-toggle-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {

      // Each Edit button stores the ID of the form it should show/hide
      var targetId = this.dataset.target;
      var form = document.getElementById(targetId);

      if (form) {
        // Toggle the 'show' CSS class to reveal or hide the inline edit form
        form.classList.toggle('show');

        // Change the button label to match the current state
        this.textContent = form.classList.contains('show') ? 'Cancel' : 'Edit';
      }
    });
  });

  // ── Confirm destructive actions ───────────────────────────────────────
  // Find every button that needs a confirmation popup before it submits
  document.querySelectorAll('.confirm-action').forEach(function (btn) {
    btn.addEventListener('click', function (e) {

      // Read the custom message from the button's data-confirm attribute
      var msg = this.dataset.confirm || 'Are you sure?';

      // If the user clicks "Cancel" in the popup, stop the form from submitting
      if (!confirm(msg)) e.preventDefault();
    });
  });

  // ── Filter appointments table ─────────────────────────────────────────
  // Grab the two filter controls and all table rows
  var statusFilter = document.getElementById('filterStatus');
  var dateFilter   = document.getElementById('filterDate');
  var tableRows    = document.querySelectorAll('#appointmentsTable tbody tr');

  // This function runs whenever a filter changes
  function applyFilters() {
    var status = statusFilter ? statusFilter.value : '';
    var date   = dateFilter   ? dateFilter.value   : '';

    // Loop through every row and decide whether to show or hide it
    tableRows.forEach(function (row) {
      var rowStatus = row.dataset.status || '';
      var rowDate   = row.dataset.date   || '';
      var show = true;

      // Hide the row if it doesn't match the selected status
      if (status && rowStatus !== status) show = false;

      // Hide the row if it doesn't match the selected date
      if (date   && rowDate   !== date)   show = false;

      row.style.display = show ? '' : 'none';
    });
  }

  // Re-run the filter whenever the user changes either dropdown/input
  if (statusFilter) statusFilter.addEventListener('change', applyFilters);
  if (dateFilter)   dateFilter.addEventListener('change',   applyFilters);

  // ── Auto-dismiss alerts ───────────────────────────────────────────────
  // Find all success/error alert banners on the page
  document.querySelectorAll('.alert').forEach(function (alert) {

    // After 4 seconds, fade the alert out and then remove it from the page
    setTimeout(function () {
      alert.style.transition = 'opacity .5s ease'; // smooth fade
      alert.style.opacity = '0';

      // Remove the element from the DOM after the fade finishes (0.5s)
      setTimeout(function () { alert.remove(); }, 500);
    }, 4000);
  });

});
