# ShopNest – Architecture & Database Design

## 1. High-Level Architecture

```
[ React SPA ] ──HTTP/JSON──► [ Spring Boot REST API ] ──► [ PostgreSQL ]
                                    │
                                    ├──► Stripe (payments + webhooks)
                                    └──► Cloudinary (product images)
```

Style: **modular monolith**, a single deployable app organised by feature.

## 2. Backend Layers
Controller → (DTO) → Service → Repository → Entity → Database

- **Controller:** HTTP only (routing, validation, status codes)
- **Service:** business rules, transactions (`@Transactional`)
- **Repository:** Spring Data JPA interfaces
- **DTOs:** API contracts; entities are never exposed directly
- **Mapper:** MapStruct converts Entity ↔ DTO

## 3. Package Structure (feature-based)

```
com.shopnest
├── ShopNestApplication.java
├── common/        # exceptions, error handler, base entity, pagination DTOs
├── config/        # security, OpenAPI, CORS, Cloudinary, Stripe config
├── security/      # JWT service, filter, UserDetails
├── auth/          # register, login, refresh, logout
├── user/          # User entity, profile
├── address/
├── category/
├── product/
├── cart/
├── order/
├── payment/
└── admin/         # dashboard
```
Each feature has: `controller`, `service`, `repository`, `entity`, `dto`, `mapper`.

## 4. Database Design (ER Diagram)

```mermaid
erDiagram
    USERS ||--o{ ADDRESSES : has
    USERS ||--o| CARTS : owns
    USERS ||--o{ ORDERS : places
    USERS ||--o{ REFRESH_TOKENS : has
    CATEGORIES ||--o{ PRODUCTS : contains
    PRODUCTS ||--o{ PRODUCT_IMAGES : has
    CARTS ||--o{ CART_ITEMS : contains
    PRODUCTS ||--o{ CART_ITEMS : "added as"
    ORDERS ||--o{ ORDER_ITEMS : contains
    PRODUCTS ||--o{ ORDER_ITEMS : "ordered as"
    ORDERS ||--o| PAYMENTS : "paid by"

    USERS {
        bigint id PK
        varchar first_name
        varchar last_name
        varchar email UK
        varchar password_hash
        varchar role "CUSTOMER | ADMIN"
        timestamp created_at
        timestamp updated_at
    }
    REFRESH_TOKENS {
        bigint id PK
        bigint user_id FK
        varchar token UK
        timestamp expires_at
        boolean revoked
    }
    ADDRESSES {
        bigint id PK
        bigint user_id FK
        varchar full_name
        varchar phone
        varchar line1
        varchar line2
        varchar city
        varchar postal_code
        boolean is_default
    }
    CATEGORIES {
        bigint id PK
        varchar name UK
        varchar slug UK
        text description
    }
    PRODUCTS {
        bigint id PK
        bigint category_id FK
        varchar name
        varchar slug UK
        varchar sku UK
        text description
        decimal price
        int stock_quantity
        boolean active
        bigint version "optimistic lock"
        timestamp created_at
        timestamp updated_at
    }
    PRODUCT_IMAGES {
        bigint id PK
        bigint product_id FK
        varchar url
        varchar public_id
        int sort_order
    }
    CARTS {
        bigint id PK
        bigint user_id FK,UK
        timestamp updated_at
    }
    CART_ITEMS {
        bigint id PK
        bigint cart_id FK
        bigint product_id FK
        int quantity
    }
    ORDERS {
        bigint id PK
        varchar order_number UK
        bigint user_id FK
        varchar status
        decimal subtotal
        decimal shipping_fee
        decimal total
        varchar ship_full_name
        varchar ship_phone
        varchar ship_line1
        varchar ship_line2
        varchar ship_city
        varchar ship_postal_code
        timestamp created_at
        timestamp updated_at
    }
    ORDER_ITEMS {
        bigint id PK
        bigint order_id FK
        bigint product_id FK
        varchar product_name "snapshot"
        decimal unit_price "snapshot"
        int quantity
        decimal line_total
    }
    PAYMENTS {
        bigint id PK
        bigint order_id FK,UK
        varchar provider "STRIPE"
        varchar provider_session_id UK
        varchar status "PENDING | SUCCEEDED | FAILED"
        decimal amount
        varchar currency
        timestamp created_at
    }
```

### Key design decisions
- **Snapshot fields** (order items, shipping address): old orders stay correct after prices or addresses change.
- **`version` on products:** optimistic locking prevents overselling.
- **Unique (cart_id, product_id):** one line per product in a cart.
- **Soft delete for products** (`active = false`): products used in old orders can't be hard-deleted.

## 5. Security
- Public: `GET /products/**`, `GET /categories/**`, `/auth/**`, Swagger, Stripe webhook
- CUSTOMER: cart, addresses, own orders, checkout
- ADMIN: `/admin/**`

## 6. Git Workflow
- `main`: stable, always working
- `feature/<name>`: one branch per step, merged into `main` via a Pull Request
- Commit style: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `test:`)