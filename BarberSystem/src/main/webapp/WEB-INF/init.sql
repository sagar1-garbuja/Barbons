
-- ── 1. Create & select database ────────────────────────────
DROP DATABASE IF EXISTS barbers_db;
CREATE DATABASE barbers_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE barbers_db;

-- ── 2. Users table ──────────────────────────────────────────
CREATE TABLE users (
  user_id         INT          NOT NULL AUTO_INCREMENT,
  full_name       VARCHAR(100) NOT NULL,
  email           VARCHAR(150) NOT NULL UNIQUE,
  phone           VARCHAR(15)  NOT NULL UNIQUE,
  password        VARCHAR(255) NOT NULL,
  role            ENUM('customer','admin') NOT NULL DEFAULT 'customer',
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  profile_picture VARCHAR(255)          DEFAULT NULL,
  created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id)
) ENGINE=InnoDB;

-- ── 3. Barbers table ────────────────────────────────────────
CREATE TABLE barbers (
  barber_id  INT          NOT NULL AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  speciality VARCHAR(150)          DEFAULT NULL,
  bio        TEXT                  DEFAULT NULL,
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (barber_id)
) ENGINE=InnoDB;

-- ── 4. Services table ───────────────────────────────────────
CREATE TABLE services (
  service_id    INT           NOT NULL AUTO_INCREMENT,
  service_name  VARCHAR(150)  NOT NULL,
  description   TEXT                   DEFAULT NULL,
  price         DECIMAL(10,2) NOT NULL,
  duration_mins INT           NOT NULL,
  is_active     TINYINT(1)    NOT NULL DEFAULT 1,
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (service_id)
) ENGINE=InnoDB;

-- ── 5. Appointments table ───────────────────────────────────
CREATE TABLE appointments (
  appointment_id INT           NOT NULL AUTO_INCREMENT,
  user_id        INT           NOT NULL,
  barber_id      INT                    DEFAULT NULL,
  service_id     INT           NOT NULL,
  appt_date      DATE          NOT NULL,
  appt_time      TIME          NOT NULL,
  status         ENUM('pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending',
  notes          TEXT                   DEFAULT NULL,
  payment_method VARCHAR(20)            DEFAULT 'cash',
  payment_status VARCHAR(20)            DEFAULT 'unpaid',
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (appointment_id),
  CONSTRAINT fk_appt_user    FOREIGN KEY (user_id)    REFERENCES users    (user_id)    ON DELETE CASCADE,
  CONSTRAINT fk_appt_barber  FOREIGN KEY (barber_id)  REFERENCES barbers  (barber_id)  ON DELETE SET NULL,
  CONSTRAINT fk_appt_service FOREIGN KEY (service_id) REFERENCES services (service_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── 6. Reviews table ────────────────────────────────────────
CREATE TABLE reviews (
  review_id      INT        NOT NULL AUTO_INCREMENT,
  appointment_id INT        NOT NULL UNIQUE,
  user_id        INT        NOT NULL,
  rating         TINYINT    NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment        TEXT                DEFAULT NULL,
  is_visible     TINYINT(1) NOT NULL DEFAULT 1,
  created_at     TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (review_id),
  CONSTRAINT fk_review_appt FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id) ON DELETE CASCADE,
  CONSTRAINT fk_review_user FOREIGN KEY (user_id)        REFERENCES users        (user_id)        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── Done ────────────────────────────────────────────────────
SELECT 'barbers_db initialized successfully. Now run seed.sql to add the admin account.' AS status;
