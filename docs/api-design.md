# ShopNest – API Design

Base URL: `/api/v1`
Auth header: `Authorization: Bearer <accessToken>`

## Auth
| Method | Endpoint          | Access | Description            |
|--------|-------------------|--------|------------------------|
| POST   | /auth/register    | Public | Register customer      |
| POST   | /auth/login       | Public | Login, returns tokens  |
| POST   | /auth/refresh     | Public | New access token       |
| POST   | /auth/logout      | Auth   | Revoke refresh token   |
| GET    | /users/me         | Auth   | Current user profile   |

## Categories
| Method | Endpoint                | Access | Description     |
|--------|-------------------------|--------|-----------------|
| GET    | /categories             | Public | List categories |
| POST   | /admin/categories       | Admin  | Create          |
| PUT    | /admin/categories/{id}  | Admin  | Update          |
| DELETE | /admin/categories/{id}  | Admin  | Delete          |

## Products
| Method | Endpoint                               | Access | Description                 |
|--------|----------------------------------------|--------|-----------------------------|
| GET    | /products                              | Public | List (filters, paging)      |
| GET    | /products/{slug}                       | Public | Product details             |
| GET    | /admin/products                        | Admin  | List all incl. inactive     |
| POST   | /admin/products                        | Admin  | Create                      |
| PUT    | /admin/products/{id}                   | Admin  | Update                      |
| PATCH  | /admin/products/{id}/stock             | Admin  | Update stock                |
| PATCH  | /admin/products/{id}/status            | Admin  | Activate / deactivate       |
| POST   | /admin/products/{id}/images            | Admin  | Upload image (multipart)    |
| DELETE | /admin/products/{id}/images/{imageId}  | Admin  | Delete image                |

**Query params for `GET /products`:**
`page=0&size=12&sort=price,asc&categoryId=1&minPrice=1000&maxPrice=5000&q=shoe`

## Addresses
| Method | Endpoint                     | Access   |
|--------|------------------------------|----------|
| GET    | /addresses                   | Customer |
| POST   | /addresses                   | Customer |
| PUT    | /addresses/{id}              | Customer |
| DELETE | /addresses/{id}              | Customer |
| PATCH  | /addresses/{id}/default      | Customer |

## Cart
| Method | Endpoint                 | Access   | Description        |
|--------|--------------------------|----------|--------------------|
| GET    | /cart                    | Customer | View cart          |
| POST   | /cart/items              | Customer | Add item           |
| PUT    | /cart/items/{itemId}     | Customer | Change quantity    |
| DELETE | /cart/items/{itemId}     | Customer | Remove item        |
| DELETE | /cart                    | Customer | Clear cart         |

## Orders & Checkout
| Method | Endpoint                   | Access   | Description                          |
|--------|----------------------------|----------|--------------------------------------|
| POST   | /orders                    | Customer | Place order from cart `{addressId}`  |
| GET    | /orders                    | Customer | My orders (paged)                    |
| GET    | /orders/{orderNumber}      | Customer | Order details                        |
| POST   | /orders/{orderNumber}/cancel | Customer | Cancel order                       |
| POST   | /orders/{orderNumber}/pay  | Customer | Create Stripe Checkout session → URL |

## Payments
| Method | Endpoint             | Access          | Description            |
|--------|----------------------|-----------------|------------------------|
| POST   | /payments/webhook    | Public (Stripe signature verified) | Stripe events |

## Admin – Orders & Dashboard
| Method | Endpoint                           | Access | Description           |
|--------|------------------------------------|--------|-----------------------|
| GET    | /admin/orders?status=PAID          | Admin  | All orders            |
| GET    | /admin/orders/{orderNumber}        | Admin  | Order details         |
| PATCH  | /admin/orders/{orderNumber}/status | Admin  | Update status         |
| GET    | /admin/dashboard                   | Admin  | Stats                 |

## Standard Error Response
```json
{
  "timestamp": "2026-11-23T10:15:30Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/v1/auth/register",
  "fieldErrors": {
    "email": "must be a well-formed email address"
  }
}
```

## Paged Response
```json
{
  "content": [ ... ],
  "page": 0,
  "size": 12,
  "totalElements": 57,
  "totalPages": 5,
  "last": false
}
```