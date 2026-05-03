-- ============================================================
-- BARBER'S — Seed Data
-- Run this AFTER creating the tables in barbers_db
-- ============================================================

USE barbers_db;

-- ── Admin User ─────────────────────────────────────────────
-- Email:    admin@barbers.com
-- Password: Admin@123
INSERT INTO users (user_id, full_name, email, phone, password, role, is_active, created_at, updated_at)
VALUES (1, 'Admin User', 'admin@barbers.com', '9800000001', MD5('Admin@123'), 'admin', 1, NOW(), NOW());

-- ── Sample Customers ───────────────────────────────────────
-- Password for all: Pass1234
INSERT INTO users (user_id, full_name, email, phone, password, role, is_active, created_at, updated_at)
VALUES
  (2, 'John Doe',     'john@email.com', '9800000002', MD5('Pass1234'), 'customer', 1, NOW(), NOW()),
  (3, 'Jane Smith',   'jane@email.com', '9800000003', MD5('Pass1234'), 'customer', 1, NOW(), NOW()),
  (4, 'Mike Johnson', 'mike@email.com', '9800000004', MD5('Pass1234'), 'customer', 1, NOW(), NOW());

-- ── Barbers ────────────────────────────────────────────────
INSERT INTO barbers (barber_id, name, speciality, bio, is_active, created_at, updated_at)
VALUES
  (1, 'Alex Rivera', 'Fades & Tapers',  'Expert in modern fades',           1, NOW(), NOW()),
  (2, 'Sam Torres',  'Classic Cuts',    'Traditional barbering specialist',  1, NOW(), NOW()),
  (3, 'Jordan Lee',  'Beard Grooming',  'Beard shaping and grooming expert', 1, NOW(), NOW());

-- ── Services ───────────────────────────────────────────────
INSERT INTO services (service_id, service_name, description, price, duration_mins, is_active, created_at, updated_at)
VALUES
  (1, 'Classic Haircut',    'Traditional cut and style',   15.00, 30, 1, NOW(), NOW()),
  (2, 'Fade Cut',           'Modern fade with precision',  20.00, 45, 1, NOW(), NOW()),
  (3, 'Beard Trim',         'Shape and trim beard',        10.00, 20, 1, NOW(), NOW()),
  (4, 'Hot Towel Shave',    'Full straight razor shave',   25.00, 45, 1, NOW(), NOW()),
  (5, 'Hair + Beard Combo', 'Haircut plus beard grooming', 30.00, 60, 1, NOW(), NOW());

-- ── Sample Appointments ────────────────────────────────────
INSERT INTO appointments (appointment_id, user_id, barber_id, service_id, appt_date, appt_time, status, notes, created_at, updated_at)
VALUES
  (1, 2, 1, 1, '2025-06-10', '09:00:00', 'completed', NULL, NOW(), NOW()),
  (2, 3, 2, 2, '2025-06-11', '10:00:00', 'confirmed', NULL, NOW(), NOW()),
  (3, 4, 3, 3, '2025-06-12', '11:00:00', 'pending',   NULL, NOW(), NOW());

-- ── Sample Reviews ─────────────────────────────────────────
INSERT INTO reviews (review_id, appointment_id, user_id, rating, comment, is_visible, created_at)
VALUES
  (1, 1, 2, 5, 'Amazing cut, very professional!', 1, NOW()),
  (2, 2, 3, 4, 'Great service, will come back.',  1, NOW());
