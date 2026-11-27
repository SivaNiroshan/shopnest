-- =========================================================
-- ShopNest - initial schema
-- =========================================================

-- ---------- USERS ----------
CREATE TABLE users (
    id             BIGSERIAL PRIMARY KEY,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(255) NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    role           VARCHAR(20)  NOT NULL DEFAULT 'CUSTOMER',
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_users_role CHECK (role IN ('CUSTOMER', 'ADMIN'))
);
CREATE UNIQUE INDEX uk_users_email_lower ON users (LOWER(email));

-- ---------- REFRESH TOKENS ----------
CREATE TABLE refresh_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT       NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token       VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ  NOT NULL,
    revoked     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens (user_id);

-- ---------- ADDRESSES ----------
CREATE TABLE addresses (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT       NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    full_name    VARCHAR(150) NOT NULL,
    phone        VARCHAR(20)  NOT NULL,
    line1        VARCHAR(255) NOT NULL,
    line2        VARCHAR(255),
    city         VARCHAR(100) NOT NULL,
    postal_code  VARCHAR(20)  NOT NULL,
    is_default   BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX idx_addresses_user ON addresses (user_id);

-- ---------- CATEGORIES ----------
CREATE TABLE categories (
    id           BIGSERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    slug         VARCHAR(120) NOT NULL UNIQUE,
    description  TEXT,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------- PRODUCTS ----------
CREATE TABLE products (
    id              BIGSERIAL PRIMARY KEY,
    category_id     BIGINT         NOT NULL REFERENCES categories (id) ON DELETE RESTRICT,
    name            VARCHAR(200)   NOT NULL,
    slug            VARCHAR(220)   NOT NULL UNIQUE,
    sku             VARCHAR(64)    NOT NULL UNIQUE,
    description     TEXT,
    price           NUMERIC(12, 2) NOT NULL,
    stock_quantity  INT            NOT NULL DEFAULT 0,
    active          BOOLEAN        NOT NULL DEFAULT TRUE,
    version         BIGINT         NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT chk_products_price CHECK (price >= 0),
    CONSTRAINT chk_products_stock CHECK (stock_quantity >= 0)
);
CREATE INDEX idx_products_category ON products (category_id);
CREATE INDEX idx_products_active   ON products (active);
CREATE INDEX idx_products_price    ON products (price);

-- ---------- PRODUCT IMAGES ----------
CREATE TABLE product_images (
    id          BIGSERIAL PRIMARY KEY,
    product_id  BIGINT       NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    url         VARCHAR(500) NOT NULL,
    public_id   VARCHAR(255) NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0
);
CREATE INDEX idx_product_images_product ON product_images (product_id);

-- ---------- CARTS ----------
CREATE TABLE carts (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT      NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE cart_items (
    id          BIGSERIAL PRIMARY KEY,
    cart_id     BIGINT NOT NULL REFERENCES carts (id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    quantity    INT    NOT NULL,
    CONSTRAINT uk_cart_items_cart_product UNIQUE (cart_id, product_id),
    CONSTRAINT chk_cart_items_qty CHECK (quantity > 0)
);

-- ---------- ORDERS ----------
CREATE TABLE orders (
    id                BIGSERIAL PRIMARY KEY,
    order_number      VARCHAR(30)    NOT NULL UNIQUE,
    user_id           BIGINT         NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    status            VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
    subtotal          NUMERIC(12, 2) NOT NULL,
    shipping_fee      NUMERIC(12, 2) NOT NULL,
    total             NUMERIC(12, 2) NOT NULL,
    ship_full_name    VARCHAR(150)   NOT NULL,
    ship_phone        VARCHAR(20)    NOT NULL,
    ship_line1        VARCHAR(255)   NOT NULL,
    ship_line2        VARCHAR(255),
    ship_city         VARCHAR(100)   NOT NULL,
    ship_postal_code  VARCHAR(20)    NOT NULL,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT chk_orders_status
        CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED'))
);
CREATE INDEX idx_orders_user       ON orders (user_id);
CREATE INDEX idx_orders_status     ON orders (status);
CREATE INDEX idx_orders_created_at ON orders (created_at);

CREATE TABLE order_items (
    id            BIGSERIAL PRIMARY KEY,
    order_id      BIGINT         NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    product_id    BIGINT         NOT NULL REFERENCES products (id) ON DELETE RESTRICT,
    product_name  VARCHAR(200)   NOT NULL,
    unit_price    NUMERIC(12, 2) NOT NULL,
    quantity      INT            NOT NULL,
    line_total    NUMERIC(12, 2) NOT NULL,
    CONSTRAINT chk_order_items_qty CHECK (quantity > 0)
);
CREATE INDEX idx_order_items_order ON order_items (order_id);

-- ---------- PAYMENTS ----------
CREATE TABLE payments (
    id                   BIGSERIAL PRIMARY KEY,
    order_id             BIGINT         NOT NULL UNIQUE REFERENCES orders (id) ON DELETE CASCADE,
    provider             VARCHAR(20)    NOT NULL DEFAULT 'STRIPE',
    provider_session_id  VARCHAR(255)   UNIQUE,
    status               VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
    amount               NUMERIC(12, 2) NOT NULL,
    currency             VARCHAR(3)     NOT NULL DEFAULT 'LKR',
    created_at           TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT chk_payments_status CHECK (status IN ('PENDING', 'SUCCEEDED', 'FAILED'))
);