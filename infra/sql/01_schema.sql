SET NAMES utf8mb4;
USE erp;

CREATE TABLE IF NOT EXISTS customers (
  customer_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(140) NOT NULL,
  gstin         VARCHAR(15) NULL,
  city          VARCHAR(60) NULL,
  credit_limit  DECIMAL(18,4) NOT NULL DEFAULT 0,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  created_at    DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  modified_at   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS items (
  item_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_code     VARCHAR(40) NOT NULL UNIQUE,
  item_name     VARCHAR(140) NOT NULL,
  uom           VARCHAR(12) NOT NULL DEFAULT 'Nos',
  standard_rate DECIMAL(18,4) NOT NULL DEFAULT 0,
  created_at    DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  modified_at   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS warehouses (
  warehouse_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  warehouse_name VARCHAR(80) NOT NULL UNIQUE,
  city           VARCHAR(60) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sales_orders (
  order_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id  BIGINT NOT NULL,
  order_date   DATE NOT NULL,
  status       VARCHAR(20) NOT NULL DEFAULT 'Draft',
  currency     CHAR(3) NOT NULL DEFAULT 'INR',
  total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
  created_at   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  modified_at  DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_so_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sales_order_lines (
  line_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  item_id  BIGINT NOT NULL,
  quantity DECIMAL(18,3) NOT NULL,
  rate     DECIMAL(18,4) NOT NULL,
  amount   DECIMAL(18,4) NOT NULL,
  CONSTRAINT fk_sol_order FOREIGN KEY (order_id) REFERENCES sales_orders(order_id),
  CONSTRAINT fk_sol_item  FOREIGN KEY (item_id)  REFERENCES items(item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS stock_ledger (
  entry_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id      BIGINT NOT NULL,
  warehouse_id BIGINT NOT NULL,
  qty_change   DECIMAL(18,3) NOT NULL,
  posting_ts   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  voucher_type VARCHAR(30) NOT NULL,
  voucher_id   BIGINT NOT NULL,
  CONSTRAINT fk_sl_item FOREIGN KEY (item_id) REFERENCES items(item_id),
  CONSTRAINT fk_sl_wh   FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS gl_entries (
  entry_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_code VARCHAR(20) NOT NULL,
  debit        DECIMAL(18,4) NOT NULL DEFAULT 0,
  credit       DECIMAL(18,4) NOT NULL DEFAULT 0,
  posting_ts   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  voucher_type VARCHAR(30) NOT NULL,
  voucher_id   BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO warehouses (warehouse_id, warehouse_name, city) VALUES
  (1, 'Gurugram Main', 'Gurugram'), (2, 'Pune Plant', 'Pune'), (3, 'Chennai Hub', 'Chennai');

INSERT IGNORE INTO items (item_id, item_code, item_name, uom, standard_rate) VALUES
  (1, 'BRK-PAD-01', 'Brake Pad Set', 'Set', 1850.5000),
  (2, 'FLT-OIL-02', 'Oil Filter', 'Nos', 320.2500),
  (3, 'SPK-PLG-03', 'Spark Plug', 'Nos', 145.7500),
  (4, 'WSH-BLD-04', 'Wiper Blade', 'Pair', 410.0000),
  (5, 'BAT-12V-05', 'Battery 12V', 'Nos', 5200.0000);

INSERT IGNORE INTO customers (customer_id, customer_name, gstin, city, credit_limit) VALUES
  (1, 'Sharma Auto Spares', '07AAAAA0000A1Z5', 'Delhi', 500000.0000),
  (2, 'सुनील ऑटो पार्ट्स', '09BBBBB1111B1Z6', 'Noida', 250000.0000),
  (3, 'Iyer Motors', '33CCCCC2222C1Z7', 'Chennai', 750000.0000),
  (4, 'Patil Garage', '27DDDDD3333D1Z8', 'Pune', 300000.0000),
  (5, 'Khanna Traders', '06EEEEE4444E1Z9', 'Gurugram', 400000.0000);
