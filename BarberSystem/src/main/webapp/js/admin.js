/**
 * admin.js — Admin panel interactions.
 * Inline edit toggles, filter table, confirm dialogs.
 */

document.addEventListener('DOMContentLoaded', function () {

  // ── Inline edit toggle ────────────────────────────────────────────────
  document.querySelectorAll('.edit-toggle-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var targetId = this.dataset.target;
      var form = document.getElementById(targetId);
      if (form) {
        form.classList.toggle('show');
        this.textContent = form.classList.contains('show') ? 'Cancel' : 'Edit';
      }
    });
  });

  // ── Confirm destructive actions ───────────────────────────────────────
  document.querySelectorAll('.confirm-action').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      var msg = this.dataset.confirm || 'Are you sure?';
      if (!confirm(msg)) e.preventDefault();
    });
  });

  // ── Filter appointments table ─────────────────────────────────────────
  var statusFilter = document.getElementById('filterStatus');
  var dateFilter   = document.getElementById('filterDate');
  var tableRows    = document.querySelectorAll('#appointmentsTable tbody tr');

  function applyFilters() {
    var status = statusFilter ? statusFilter.value : '';
    var date   = dateFilter   ? dateFilter.value   : '';

    tableRows.forEach(function (row) {
      var rowStatus = row.dataset.status || '';
      var rowDate   = row.dataset.date   || '';
      var show = true;
      if (status && rowStatus !== status) show = false;
      if (date   && rowDate   !== date)   show = false;
      row.style.display = show ? '' : 'none';
    });
  }

  if (statusFilter) statusFilter.addEventListener('change', applyFilters);
  if (dateFilter)   dateFilter.addEventListener('change',   applyFilters);

  // ── Auto-dismiss alerts ───────────────────────────────────────────────
  document.querySelectorAll('.alert').forEach(function (alert) {
    setTimeout(function () {
      alert.style.transition = 'opacity .5s ease';
      alert.style.opacity = '0';
      setTimeout(function () { alert.remove(); }, 500);
    }, 4000);
  });

});
