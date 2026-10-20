
CREATE DATABASE IF NOT EXISTS digital_evidence_analyzer
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE digital_evidence_analyzer;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN','INVESTIGATOR','VIEWER')
    NOT NULL DEFAULT 'INVESTIGATOR',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cases (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  case_code VARCHAR(40) NOT NULL UNIQUE,
  case_name VARCHAR(180) NOT NULL,
  description TEXT,
  status ENUM('OPEN','UNDER_ANALYSIS','UNDER_REVIEW','CLOSED')
    NOT NULL DEFAULT 'OPEN',
  created_by BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_cases_user
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS evidence_files (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  case_id BIGINT NOT NULL,
  evidence_code VARCHAR(40) NOT NULL UNIQUE,
  file_name VARCHAR(255) NOT NULL,
  file_path TEXT NOT NULL,
  file_type VARCHAR(100),
  file_size BIGINT,
  created_time DATETIME,
  modified_time DATETIME,
  accessed_time DATETIME,
  registered_sha256 CHAR(64),
  current_sha256 CHAR(64),
  md5 CHAR(32),
  integrity_status ENUM('NOT_CHECKED','VERIFIED','HASH_MISMATCH')
    DEFAULT 'NOT_CHECKED',
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_evidence_case
    FOREIGN KEY (case_id)
    REFERENCES cases(id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS suspicious_indicators (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  evidence_id BIGINT NOT NULL,
  indicator_type VARCHAR(100) NOT NULL,
  severity ENUM('LOW','MEDIUM','HIGH') DEFAULT 'MEDIUM',
  description VARCHAR(500),
  detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (evidence_id)
    REFERENCES evidence_files(id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  case_id BIGINT,
  action VARCHAR(120) NOT NULL,
  details TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE SET NULL,
  FOREIGN KEY (case_id)
    REFERENCES cases(id)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS finding_reviews (
  id BIGINT NOT NULL AUTO_INCREMENT,
  evidence_id BIGINT NOT NULL,
  finding_type VARCHAR(100) NOT NULL,
  review_status ENUM('UNDER REVIEW','VERIFIED','REJECTED')
    NOT NULL DEFAULT 'UNDER REVIEW',
  reviewed_by BIGINT DEFAULT NULL,
  review_comment VARCHAR(1000) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_finding_review (evidence_id, finding_type),
  KEY idx_finding_review_status (review_status),
  KEY idx_finding_review_user (reviewed_by),

  CONSTRAINT fk_finding_review_evidence
    FOREIGN KEY (evidence_id)
    REFERENCES evidence_files(id),

  CONSTRAINT fk_finding_review_user
    FOREIGN KEY (reviewed_by)
    REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_evidence_case
  ON evidence_files(case_id);

CREATE INDEX IF NOT EXISTS idx_evidence_sha256
  ON evidence_files(current_sha256);

CREATE INDEX IF NOT EXISTS idx_indicator_evidence
  ON suspicious_indicators(evidence_id);

CREATE INDEX IF NOT EXISTS idx_audit_case
  ON audit_logs(case_id);
