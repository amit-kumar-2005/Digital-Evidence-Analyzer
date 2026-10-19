# Phase 2 — Database, Authentication & Case Management

## Implemented
- MySQL/JDBC data access
- PBKDF2 password hashing
- Session-based authentication
- Role field support: ADMIN, INVESTIGATOR, VIEWER
- Initial setup endpoint for the first administrator
- Dynamic dashboard counters
- Investigation case creation and listing
- Case status model
- Phase 2 login and case-management JSP pages

## First-run sequence
1. Import `database/schema.sql` into MySQL.
2. Verify `DBConnection.java` username/password.
3. Build with Maven.
4. Deploy the WAR to Tomcat.
5. Open `/setup` once to create the initial administrator.
6. Sign in at `/login`.
7. Create a case from `/cases`.

Default academic setup credentials:
- Email: `admin@dea.local`
- Password: `Admin@123`

Change/replace these credentials before any real deployment.
