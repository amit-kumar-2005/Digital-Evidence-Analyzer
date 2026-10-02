# Digital Evidence Analyzer

A Java-based, case-oriented digital evidence investigation and integrity analysis system for academic use.

## Phase 1 foundation
- Maven WAR project
- Java 17 + Jakarta Servlet 6 / Tomcat 10.1+
- Professional dashboard shell
- Core file scanning and SHA-256/MD5 hashing engine
- File type and predefined suspicious-indicator detection
- MySQL relational schema for users, cases, evidence, indicators and audit logs

## Planned modules
Dashboard, Cases, Evidence, Analysis, Timeline, Duplicates, Indicators, Integrity, Relationships, Findings, Audit Log, Reports, Settings.

## Run
1. Install JDK 17+, Maven, MySQL 8+, Tomcat 10.1+.
2. Run `database/schema.sql` in MySQL.
3. Update DB credentials in `DBConnection.java`.
4. Run `mvn clean package`.
5. Deploy `target/digital-evidence-analyzer.war` to Tomcat.
6. Open `/digital-evidence-analyzer/dashboard`.

## Academic safety
The system reports technical indicators. It does not determine whether a file is malware or whether a person is guilty. Use only authorized evidence or test data.
