# ShopNest 🛒

A full-stack e-commerce platform built with **Java 21 + Spring Boot** and **React + TypeScript**.

Customers can browse products, manage a cart, check out with Stripe (test mode) and track orders.
Admins can manage products, categories, stock and orders.

## Tech Stack

**Backend:** Java 21, Spring Boot, Spring Security (JWT), Spring Data JPA, PostgreSQL, Flyway, MapStruct, Lombok, springdoc-openapi
**Frontend:** React, TypeScript, Vite, TanStack Query, React Router, Tailwind CSS
**Integrations:** Stripe (payments), Cloudinary (images)
**Testing:** JUnit 5, Mockito, Testcontainers
**DevOps:** Docker, Docker Compose, GitHub Actions

## Documentation

- [Requirements](docs/01-requirements.md)
- [Architecture & Database Design](docs/02-architecture.md)
- [API Design](docs/03-api-design.md)

## Project Status

🚧 In development

## Getting Started

### Prerequisites
- Java 21
- Docker Desktop

### Run locally
```bash
# 1. Start PostgreSQL
cp .env.example .env
docker compose up -d

# 2. Run the backend
cd backend
./mvnw spring-boot:run        # Windows: mvnw.cmd spring-boot:run
```

- API health: http://localhost:8080/actuator/health
- Swagger UI: http://localhost:8080/swagger-ui.html