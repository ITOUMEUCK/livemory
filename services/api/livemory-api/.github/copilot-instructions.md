# Livemory API - AI Agent Instructions

## Project Overview
This is a Spring Boot 3.4 REST API service for Livemory - a collaborative event planning platform. Using Java 17, PostgreSQL 16, and Flyway for database migrations. The application follows a standard Spring Boot layered architecture with feature-based packaging.

## Domain Model
Livemory manages group events with these core concepts:
- **Events**: Main events (weekends, parties, city trips) with multiple steps
- **Steps**: Individual activities/phases within an event
- **Participants**: Users assigned to full events or specific steps
- **Tasks**: Action items with assignments and status tracking
- **Budgets & Payments**: Financial tracking per event
- **Votes**: Group decision-making for locations, times, activities
- **Partner Offers**: Exclusive group discounts (restaurants, hotels, activities)
- **Media**: Photo/video albums for event memories

## Architecture & Structure

### Package Naming Convention
- **Critical**: Package names use underscores: `com.livemory.livemory_api` (not hyphens)
- The artifact ID is `livemory-api` (hyphenated), but Java packages cannot contain hyphens
- This was automatically corrected during Spring Initializr project creation

### Layered Architecture Pattern
Each feature follows this structure within its package:
```
feature/
  ├── Entity.java          # JPA entity
  ├── EntityRepository.java # Spring Data JPA repository
  ├── EntityService.java    # Business logic (@Service, @Transactional)
  ├── EntityController.java # REST endpoints (@RestController)
  ├── CreateEntityRequest.java # DTO for creation
  ├── EntityResponse.java   # DTO for responses (with static from() mapper)
  └── EntityType.java       # Enums if needed
```

Examples: `user/`, `event/`, `step/`, `task/`, `budget/`, `payment/`, `vote/`, `offer/`, `media/`, `participant/`

### Key Components
- **Main Application**: [LivemoryApiApplication.java](src/main/java/com/livemory/livemory_api/LivemoryApiApplication.java) - Standard Spring Boot entry point
- **Controllers**: REST controllers in feature packages (e.g., [UserController.java](src/main/java/com/livemory/livemory_api/user/UserController.java))
- **API Versioning**: All endpoints use `/api/v1/` prefix
- **Database Migrations**: Flyway versioned migrations in [src/main/resources/db/migration/](src/main/resources/db/migration/)

## Database & Persistence

### Flyway Migration Pattern
- Migrations follow `V{number}__{description}.sql` naming (e.g., `V2__create_core_tables.sql`)
- Current migrations:
  - V1: Health check table
  - V2: Core tables (users, events, steps, participants)
  - V3: Tasks table
  - V4: Budget and payment tables
  - V5: Vote tables (votes, vote_options, user_votes)
  - V6: Partner offers table
  - V7: Media table
- Flyway is configured to run automatically on startup (`spring.flyway.enabled=true`)
- JPA DDL is set to **validate** mode (`spring.jpa.hibernate.ddl-auto=validate`) - schema changes MUST be via Flyway migrations, not JPA auto-generation

### Database Configuration
- PostgreSQL 16 running in Docker (see [docker-compose.yml](docker-compose.yml))
- Default credentials: `livemory/livemory` on port 5432
- Database name: `livemory`
- JPA `open-in-view` is **disabled** for better performance and avoiding lazy-loading issues

### Entity Relationships
- Events have many Steps (1:N)
- Events have many Participants (1:N), Participants can be event-wide or step-specific
- Events have many Tasks, Tasks can be step-specific (1:N)
- Events have one Budget (1:1), many Payments (1:N)
- Events have many Votes (1:N), Votes have many VoteOptions (1:N)
- Users vote on VoteOptions tracked via UserVote (M:N)
- Events have many Media items (photos/videos) (1:N)

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
- Place controllers in feature-based sub-packages (e.g., `user/`, `event/`, `task/`)
- Return plain Java objects/primitives - Spring handles JSON serialization
- Use `@Valid` for request validation with Jakarta Validation annotations
- HTTP status codes: `@ResponseStatus(HttpStatus.CREATED)` for POST, `NO_CONTENT` for DELETE

### DTO Pattern
- Use Java records for request/response DTOs
- Request DTOs: `CreateEntityRequest` with validation annotations
- Response DTOs: `EntityResponse` with static `from(Entity entity)` mapper method
- Example: [UserResponse.java](src/main/java/com/livemory/livemory_api/user/UserResponse.java)

### Service Layer Pattern
- Annotate with `@Service` and `@Transactional`
- Read-only operations: `@Transactional(readOnly = true)`
- Inject repositories via constructor injection
- Throw `IllegalArgumentException` for business validation errors

### Repository Pattern
- Extend `JpaRepository<Entity, Long>`
- Use Spring Data JPA query methods (e.g., `findByEventId`, `findByCreatedById`)
- Place custom queries in repository interfaces

### When Adding New Endpoints
1. Create entity in appropriate feature package under `com.livemory.livemory_api`
2. Create Flyway migration with next version number (V8, V9, etc.)
3. Create repository extending JpaRepository
4. Create request/response DTOs as records
5. Create service with @Service and @Transactional
6. Create controller with `/api/v1/{resource}` URL pattern
7. Never modify `spring.jpa.hibernate.ddl-auto` - it must remain `validate`

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
