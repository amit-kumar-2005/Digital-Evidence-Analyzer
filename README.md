# Digital Evidence Analyzer

A Java-based interactive digital evidence investigation and integrity analysis system for academic use.

## Current Phase
**Phase 2 — Database, Authentication & Case Management**

## Technology
- Java 17+ (tested with JDK 21)
- Jakarta Servlets / JSP
- MySQL + JDBC
- Apache Tomcat 10.1
- HTML/CSS/JavaScript
- Maven

## Phase 2 Features
- Login and logout
- Session management
- Role field support
- PBKDF2 password hashing
- MySQL/JDBC integration
- Dynamic dashboard counters
- Investigation case creation
- Case listing and status display

## Run
1. Import `database/schema.sql` in MySQL.
2. Set the MySQL username/password in `DBConnection.java`.
3. Run `mvn clean package`.
4. Copy `target/digital-evidence-analyzer.war` to Tomcat `webapps`.
5. Start Tomcat.
6. Open `/digital-evidence-analyzer/setup` once.
7. Open `/digital-evidence-analyzer/login`.

Academic prototype only. The application presents technical indicators and does not make legal conclusions.
