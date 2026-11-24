CREATE TABLE IF NOT EXISTS warehouses (
  warehouse_id BIGINT PRIMARY KEY,
  warehouse_name VARCHAR(100) NOT NULL,
  city VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS items (
  item_id BIGINT PRIMARY KEY,
  item_code VARCHAR(20) NOT NULL,
  item_name VARCHAR(100) NOT NULL,
  uom VARCHAR(20),
  standard_rate DECIMAL(18,4) NOT NULL
);
CREATE TABLE IF NOT EXISTS customers (
  customer_id BIGINT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  gstin VARCHAR(20),
  city VARCHAR(50),
  credit_limit DECIMAL(18,4) NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS sales_orders (
  order_id BIGINT PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(customer_id),
  created_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS sales_order_lines (
  line_id BIGINT PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES sales_orders(order_id),
  item_id BIGINT NOT NULL REFERENCES items(item_id),
  quantity DECIMAL(18,3) NOT NULL,
  rate DECIMAL(18,4) NOT NULL,
  amount DECIMAL(18,4) NOT NULL
);
CREATE TABLE IF NOT EXISTS stock_ledger (
  entry_id BIGINT PRIMARY KEY,
  item_id BIGINT NOT NULL REFERENCES items(item_id),
  warehouse_id BIGINT NOT NULL REFERENCES warehouses(warehouse_id),
  qty_change DECIMAL(18,3) NOT NULL,
  posting_ts TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  voucher_type VARCHAR(30) NOT NULL,
  voucher_id BIGINT NOT NULL
);
CREATE TABLE IF NOT EXISTS gl_entries (
  entry_id BIGINT PRIMARY KEY,
  account_code VARCHAR(20) NOT NULL,
  debit DECIMAL(18,4) NOT NULL DEFAULT 0,
  credit DECIMAL(18,4) NOT NULL DEFAULT 0,
  posting_ts TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  voucher_type VARCHAR(30) NOT NULL,
  voucher_id BIGINT NOT NULL
);
