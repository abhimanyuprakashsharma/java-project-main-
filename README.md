# Trendify — Modern Boutique & Lifestyle E-Commerce Project

Trendify is an educational Java e-commerce capstone aligned with the RTU Advanced Java project guide. The core application is a layered Jakarta Servlet/JSP web store, with focused Swing, networking, RMI, serialization, JNDI and internationalization modules for syllabus demonstration.

## Project status

**Application development and local testing: complete.**  
**Repository audit and deployment preparation: complete.**  
**Next stage: hosted deployment.**

## Technology

- Java 17 target
- Jakarta Servlet 6.1 + JSP/JSTL
- JDBC + MySQL
- Maven WAR + Apache Tomcat 11
- Java Swing
- java.net Socket/ServerSocket
- Java RMI + RMI Registry
- JNDI
- Object serialization
- Servlet filters/listeners
- Cookies, EL, JSTL and internationalization

## Architecture

Browser → JSP/HTML/JS → Servlet → Service → DAO → JDBC → MySQL

Advanced modules remain separate from the main shopping workflow:
- Networking: com.shopsphere.network
- RMI: com.shopsphere.rmi
- Serialization: com.shopsphere.serialization
- Swing: com.shopsphere.desktop
- JNDI: com.shopsphere.jndi
- Web infrastructure: com.shopsphere.web

## Core functionality

Customer:
- Registration, login/logout and profile
- Product listing, search, sorting and pagination
- Product details, reviews and ratings
- Cart and wishlist
- Saved addresses
- Coupons and checkout
- Local/mock payment recording
- Order history and customer-owned order details

Admin:
- Dashboard
- Product/category/inventory management
- Customer management with account safety rules
- Order management
- Review moderation
- Sales analytics
- Coupon management
- Order CSV export

## Security and hardening

- PBKDF2 password hashing and password policy
- PreparedStatement-based JDBC
- Server-side input validation
- CSRF same-origin protection
- Security headers and CSP
- Authentication/Admin filters
- Session timeout and cookie-only tracking
- No-store responses for session-backed requests
- Login attempt throttling
- Customer/admin ownership checks
- DB-backed health endpoint
- Correlation/request logging

## RTU syllabus demonstrations

- ServletConfig / ServletContext: /syllabus/config-context
- JSP declarations/scriptlets/expressions: /syllabus/demo/jsp
- JSP fragments and tag files: /syllabus/demo/components
- JSTL Core: /syllabus/demo/components
- JSTL XML: /syllabus/demo/xml
- JSTL SQL: /syllabus/demo/sql
- Socket commands: GET_PRODUCT, GET_STOCK, SEARCH_PRODUCT
- RMI inventory service and registry
- Serialization
- Swing MVC
- URL/URLConnection
- Locale + ResourceBundle: /language?lang=en or /language?lang=hi
- JNDI DataSource lookup
- Applet topic documented as a historical concept, matching the guide

## Documentation

- Final Audit Report: AUDIT-REPORT.md
- Deployment Checklist: DEPLOYMENT-CHECKLIST.md
- Architecture: ARCHITECTURE.md
- RTU Mapping: RTU-MAPPING.md
- Final Report: FINAL-REPORT.md
- Viva Checklist: VIVA-CHECKLIST.md
- Phase documentation: PHASE6.md, PHASES-8-10.md, PHASES-11-15.md, PHASES-16-20.md, PHASES-21-25.md, PHASES-26-45.md, PHASES-46-60.md
- Applet History: APPLET-HISTORY.md

## Database

Import:
- database/shopsphere.sql
- database/seed.sql

For deployment, configure the Tomcat jdbc/ShopSphereDB JNDI datasource. DBConnection also supports SHOPSPHERE_DB_URL, SHOPSPHERE_DB_USER and SHOPSPHERE_DB_PASSWORD environment variables.

## Build and test

mvn clean test package

The GitHub Actions workflow runs the same Maven verification command.

## Deployment

Build target/shopsphere.war and deploy it to Tomcat 11. The repository includes deploy/tomcat/context.xml as the JNDI datasource template.

**Never commit real database credentials.** The deployment template uses CHANGE_ME; configure the real production credential on the server.

## Important scope note

The RTU guide's official academic development plan is Phases 1–17. The repository's later numbered hardening batches extend that plan. Payment remains local/mock rather than a live gateway, and the login limiter is intentionally in-memory for this student project.
