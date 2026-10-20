# Phase 2 — Database, Authentication and Case Management

## Objective

Phase 2 established the database connection, authentication workflow, session handling, role-based permissions, and investigation case management for the Digital Evidence Analyzer project.

## Implemented Foundation

- MySQL database integration using JDBC
- Password hashing support
- Session-based authentication and logout
- Role support for ADMIN, INVESTIGATOR, and VIEWER
- Initial administrator setup workflow
- Dashboard counters and investigation records
- Case creation and listing
- Evidence registration and database records
- Audit logging foundation

## Access Control

- **ADMIN:** Administrative access and permitted investigation operations.
- **INVESTIGATOR:** Access to investigation workflows and permitted case/evidence operations.
- **VIEWER:** Read-only access to supported pages and records.

Authorization must be enforced on the server side, not only by hiding interface controls.

## Database Configuration

The application reads its database configuration from environment variables:

- `DEA_DB_PASSWORD` — required database password
- `DEA_DB_USER` — optional username; defaults to `root`
- `DEA_DB_URL` — optional JDBC URL with a local database default

Database passwords must not be stored in source code or committed to the public repository.

## Build and Deployment

1. Import `database/schema.sql` into the configured MySQL database.
2. Set the required database environment variables.
3. Run `mvn clean package`.
4. Deploy the generated WAR file to Apache Tomcat 10.1.
5. Complete the application's configured initial administrator setup, if required.
6. Sign in and test the authorized application workflows.

## Verification

The project has undergone local checks covering database connectivity, authentication, session expiry, role-based access restrictions, case creation, and evidence registration. Re-run these tests after relevant code changes.

## Limitations

This phase establishes the application's foundation. Successful builds and selected local tests do not guarantee that every analysis module has been fully verified.

The system is an academic prototype and is not a substitute for validated forensic tools or legally approved evidence-handling procedures.
