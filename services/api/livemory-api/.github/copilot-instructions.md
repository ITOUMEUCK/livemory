# Livemory API - AI Agent Instructions

## Project Overview
This is a Spring Boot 3.4 REST API service for Livemory, using Java 17, PostgreSQL 16, and Flyway for database migrations. The application follows a standard Spring Boot layered architecture.

## Architecture & Structure

### Package Naming Convention
- **Critical**: Package names use underscores: `com.livemory.livemory_api` (not hyphens)
- The artifact ID is `livemory-api` (hyphenated), but Java packages cannot contain hyphens
- This was automatically corrected during Spring Initializr project creation

### Key Components
- **Main Application**: [LivemoryApiApplication.java](src/main/java/com/livemory/livemory_api/LivemoryApiApplication.java) - Standard Spring Boot entry point
- **Controllers**: Located in feature-based packages (e.g., `health/`) under main package
- **API Versioning**: All endpoints use `/api/v1/` prefix (see [PingController.java](src/main/java/com/livemory/livemory_api/health/PingController.java))
- **Database Migrations**: Flyway versioned migrations in [src/main/resources/db/migration/](src/main/resources/db/migration/)

## Database & Persistence

### Flyway Migration Pattern
- Migrations follow `V{number}__{description}.sql` naming (e.g., `V1__init.sql`)
- Flyway is configured to run automatically on startup (`spring.flyway.enabled=true`)
- JPA DDL is set to **validate** mode (`spring.jpa.hibernate.ddl-auto=validate`) - schema changes MUST be via Flyway migrations, not JPA auto-generation
- Example: [V1__init.sql](src/main/resources/db/migration/V1__init.sql) creates `app_healthcheck` table

### Database Configuration
- PostgreSQL 16 running in Docker (see [docker-compose.yml](docker-compose.yml))
- Default credentials: `livemory/livemory` on port 5432
- Database name: `livemory`
- JPA `open-in-view` is **disabled** for better performance and avoiding lazy-loading issues

## Development Workflows

### Running the Application
```bash
# Start PostgreSQL
docker-compose up -d

# Run the Spring Boot application
./mvnw spring-boot:run
# or on Windows
mvnw.cmd spring-boot:run

# Application runs on http://localhost:8080
```

### Testing
```bash
# Run all tests
./mvnw test

# Package application
./mvnw clean package
```

### Health Checks
- Custom ping endpoint: `GET /api/v1/ping` → returns `"pong"`
- Spring Actuator health: `GET /actuator/health`
- Only `health` and `info` actuator endpoints are exposed (see [application.properties](src/main/resources/application.properties))

## Project-Specific Conventions

### REST Controller Pattern
- Use `@RestController` annotation (not `@Controller` + `@ResponseBody`)
- Place controllers in feature-based sub-packages (e.g., `health/`, future: `users/`, `memories/`)
- Return plain Java objects/primitives - Spring handles JSON serialization

### When Adding New Endpoints
1. Create controller in appropriate feature package under `com.livemory.livemory_api`
2. Use `/api/v1/{resource}` URL pattern
3. Add any new database schema via Flyway migration (increment version number)
4. Never modify `spring.jpa.hibernate.ddl-auto` - it must remain `validate`

### Dependencies
- Web: `spring-boot-starter-web` for REST APIs
- Data: `spring-boot-starter-data-jpa` with PostgreSQL driver
- Validation: `spring-boot-starter-validation` available for request validation
- Migrations: `flyway-database-postgresql` for version-controlled schema changes
- Monitoring: `spring-boot-starter-actuator` with minimal exposure

## Integration Points
- **Database**: PostgreSQL via JPA/Hibernate with Flyway migrations
- **Container**: Docker Compose manages PostgreSQL with persistent volume `livemory_pg`
- **Future considerations**: This appears to be one service in a larger "livemory" system (note workspace path: `services/api/`)
