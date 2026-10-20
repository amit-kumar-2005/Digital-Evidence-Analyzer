# Digital Evidence Analyzer

A Java-based web application for organizing digital evidence investigations, checking file integrity, identifying suspicious indicators, and maintaining investigation records. This project is developed for academic use as part of the Advanced Java Programming PBL.

## Technology Stack

- Java 21
- Jakarta Servlets and JSP
- Apache Maven
- MySQL and JDBC
- Apache Tomcat 10.1
- HTML, CSS, and JavaScript
- Java Security and NIO APIs

## Main Modules

- Authentication and session management
- Role-based access control: ADMIN, INVESTIGATOR, and VIEWER
- Investigation case management
- Evidence registration and records
- Evidence integrity verification
- Suspicious indicator analysis
- Duplicate evidence detection
- Timeline and relationship analysis
- Findings and reports
- Audit log

Module availability and analysis results depend on the current implementation and test data.

## Prerequisites

Install and configure:

- JDK 21
- Apache Maven
- MySQL Server 8.0 or compatible version
- Apache Tomcat 10.1

## Database Setup

1. Start the MySQL service.
2. Create or configure the `digital_evidence_analyzer` database.
3. Import `database/schema.sql` into MySQL.
4. Configure the database connection using environment variables.

Set the following environment variables:

- `DEA_DB_PASSWORD` — required MySQL password
- `DEA_DB_USER` — MySQL username; defaults to `root`
- `DEA_DB_URL` — JDBC URL; defaults to `jdbc:mysql://localhost:3306/digital_evidence_analyzer?useSSL=false&serverTimezone=Asia/Kolkata`

Do not commit database passwords, private credentials, or real evidence files to GitHub.

## Build the Project

From the project root, run:

```powershell
mvn clean package
```

The generated WAR file should be available at:

`target/digital-evidence-analyzer.war`

## Deploy on Tomcat

1. Copy the generated WAR file to Tomcat's `webapps` directory.
2. Ensure Tomcat starts with the required Java configuration and database environment variables.
3. Start or restart Tomcat.
4. Open the deployed application using its configured context path.

For a local deployment using port 8081 and the WAR filename above, the application context is normally:

`http://localhost:8081/digital-evidence-analyzer/`

Use the application's configured login and initial administrator setup procedure.

## Development and Testing

Build and test changes before committing them. Use sample or synthetic evidence files during development. Test authentication, role permissions, evidence registration, integrity verification, and audit logging.

## Disclaimer

This is an academic prototype. Analysis results and suspicious indicators are intended to support investigation and learning; they do not independently establish malware, criminal activity, or legal conclusions. The application should not be treated as a certified forensic platform.
