/**
 * auth.js — Client-side validation for login and register forms.
 * No libraries. Runs before form submit.
 */

document.addEventListener('DOMContentLoaded', function () {

  // ── Password eye toggles ──────────────────────────────────────────────
  document.querySelectorAll('.eye-toggle').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var input = this.previousElementSibling;
      if (!input || input.tagName !== 'INPUT') {
        input = this.parentElement.querySelector('input');
      }
      if (input.type === 'password') {
        input.type = 'text';
        this.innerHTML = '&#128065;&#65038;'; // eye with slash
      } else {
        input.type = 'password';
        this.innerHTML = '&#128065;'; // eye
      }
    });
  });

  // ── Password strength meter ───────────────────────────────────────────
  var pwdInput = document.getElementById('password');
  var strengthFill  = document.querySelector('.strength-fill');
  var strengthLabel = document.querySelector('.strength-label');

  if (pwdInput && strengthFill) {
    pwdInput.addEventListener('input', function () {
      var val = this.value;
      var score = 0;
      if (val.length >= 8)          score++;
      if (/[A-Z]/.test(val))        score++;
      if (/\d/.test(val))           score++;
      if (/[^A-Za-z0-9]/.test(val)) score++;

      var pct   = (score / 4) * 100;
      var color = score <= 1 ? '#c0392b' : score === 2 ? '#f39c12' : '#27ae60';
      var label = score <= 1 ? 'Weak' : score === 2 ? 'Fair' : 'Strong';

      strengthFill.style.width      = pct + '%';
      strengthFill.style.background = color;
      if (strengthLabel) strengthLabel.textContent = label;
    });
  }

  // ── Register form validation ──────────────────────────────────────────
  var registerForm = document.getElementById('registerForm');
  if (registerForm) {
    registerForm.addEventListener('submit', function (e) {
      var valid = true;

      // Full name
      valid = validateRequired('fullName', 'Full name is required.') && valid;

      // Email
      var emailVal = getVal('email');
      if (!emailVal) {
        showError('email', 'Email is required.');
        valid = false;
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailVal)) {
        showError('email', 'Enter a valid email address.');
        valid = false;
      } else {
        clearError('email');
      }

      // Phone
      var phoneVal = getVal('phone');
      if (!phoneVal) {
        showError('phone', 'Phone number is required.');
        valid = false;
      } else if (!/^\d{10}$/.test(phoneVal)) {
        showError('phone', 'Phone must be exactly 10 digits.');
        valid = false;
      } else {
        clearError('phone');
      }

      // Password
      var pwdVal = getVal('password');
      if (!pwdVal) {
        showError('password', 'Password is required.');
        valid = false;
      } else if (!/(?=.*\d).{8,}/.test(pwdVal)) {
        showError('password', 'Min 8 characters with at least one number.');
        valid = false;
      } else {
        clearError('password');
      }

      // Confirm password
      var confirmVal = getVal('confirmPassword');
      if (!confirmVal) {
        showError('confirmPassword', 'Please confirm your password.');
        valid = false;
      } else if (confirmVal !== pwdVal) {
        showError('confirmPassword', 'Passwords do not match.');
        valid = false;
      } else {
        clearError('confirmPassword');
      }

      if (!valid) {
        e.preventDefault();
        // Scroll to first error
        var firstErr = document.querySelector('.field-error.show');
        if (firstErr) firstErr.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    });
  }

  // ── Login form validation ─────────────────────────────────────────────
  var loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', function (e) {
      var valid = true;

      var emailVal = getVal('email');
      if (!emailVal) {
        showError('email', 'Email is required.');
        valid = false;
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailVal)) {
        showError('email', 'Enter a valid email address.');
        valid = false;
      } else {
        clearError('email');
      }

      if (!getVal('password')) {
        showError('password', 'Password is required.');
        valid = false;
      } else {
        clearError('password');
      }

      if (!valid) e.preventDefault();
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  function getVal(id) {
    var el = document.getElementById(id);
    return el ? el.value.trim() : '';
  }

  function validateRequired(id, msg) {
    if (!getVal(id)) { showError(id, msg); return false; }
    clearError(id);
    return true;
  }

  function showError(id, msg) {
    var el = document.getElementById('err-' + id);
    if (el) { el.textContent = msg; el.classList.add('show'); }
  }

  function clearError(id) {
    var el = document.getElementById('err-' + id);
    if (el) el.classList.remove('show');
  }
});
