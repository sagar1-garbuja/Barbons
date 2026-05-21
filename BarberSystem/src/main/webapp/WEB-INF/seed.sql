USE barbers_db;

-- ── Admin account ────────────────────────────────────────────
-- Login: admin@barbers.com / Admin@123
INSERT INTO users (full_name, email, phone, password, role, is_active)
VALUES ('Admin', 'admin@barbers.com', '9800000000', MD5('Admin@123'), 'admin', 1);

-- ── Done ────────────────────────────────────────────────────
SELECT 'Admin account created. Login at /login.jsp with admin@barbers.com / Admin@123' AS status;

