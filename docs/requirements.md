# ShopNest – Requirements

## 1. Overview
ShopNest is a single-store e-commerce web application. Customers buy products online;
an admin manages the catalog and fulfils orders.

## 2. User Roles
| Role      | Description                                      |
|-----------|--------------------------------------------------|
| Guest     | Not logged in. Can browse and search products.   |
| Customer  | Registered user. Can use cart, checkout, orders. |
| Admin     | Manages products, categories, stock and orders.  |

## 3. Functional Requirements (MVP)

### 3.1 Authentication
- FR-1: A guest can register with first name, last name, email and password.
- FR-2: A user can log in with email and password and receive a JWT access token + refresh token.
- FR-3: A user can refresh an expired access token using a valid refresh token.
- FR-4: A user can log out (refresh token is revoked).
- FR-5: Passwords are stored hashed (BCrypt).

### 3.2 Product Catalog
- FR-6: Anyone can list products with pagination.
- FR-7: Anyone can filter products by category and price range, search by name, and sort by price/newest.
- FR-8: Anyone can view a product's details and images.
- FR-9: Anyone can list categories.
- FR-10: Only active products are visible to non-admins.

### 3.3 Cart
- FR-11: A customer has one cart.
- FR-12: A customer can add a product to the cart, change quantity and remove items.
- FR-13: Quantity cannot exceed available stock.
- FR-14: Cart shows line totals and cart subtotal.

### 3.4 Addresses
- FR-15: A customer can add, edit, delete addresses and mark one as default.

### 3.5 Checkout & Orders
- FR-16: A customer can place an order from the cart using a selected address.
- FR-17: On order placement, stock is reserved (decremented) and the cart is cleared.
- FR-18: Product name and price are copied into the order (snapshot) at purchase time.
- FR-19: A customer can view their order history and order details.
- FR-20: A customer can cancel an order while it is PENDING or PAID (stock is restored).

### 3.6 Payments
- FR-21: Payment is done via Stripe Checkout (test mode).
- FR-22: Order becomes PAID only when Stripe confirms payment via webhook.
- FR-23: Unpaid orders older than 30 minutes are cancelled automatically and stock is restored.

### 3.7 Admin
- FR-24: Admin can create, update, deactivate products and upload product images.
- FR-25: Admin can create, update, delete categories (only if no products use them).
- FR-26: Admin can update stock quantity.
- FR-27: Admin can view all orders, filter by status, and update status (SHIPPED, DELIVERED).
- FR-28: Admin can see a simple dashboard (total orders, revenue, low-stock products).

## 4. Order Status Flow
PENDING ──(payment success)──► PAID ──► SHIPPED ──► DELIVERED
│                            │
└──(cancel / timeout)──► CANCELLED ◄──(cancel)

## 5. Non-Functional Requirements
- NFR-1: REST API, JSON, versioned under `/api/v1`.
- NFR-2: Stateless auth using JWT; access token 15 min, refresh token 7 days.
- NFR-3: Consistent error response format for all errors.
- NFR-4: Input validated on server side.
- NFR-5: No overselling – concurrent purchases handled with optimistic locking.
- NFR-6: API documented with Swagger UI.
- NFR-7: Whole system runs with one command using Docker Compose.
- NFR-8: Unit and integration tests for core business logic.
- NFR-9: Secrets supplied via environment variables, never committed.

## 6. Business Rules
- Currency: LKR. Prices stored as DECIMAL(12,2).
- Flat shipping fee: LKR 500; free shipping for subtotal ≥ LKR 10,000.
- Email is unique and case-insensitive.

## 7. Out of Scope (MVP)
Reviews, wishlist, coupons, multi-vendor, email notifications, product variants (size/colour).