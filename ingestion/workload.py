import random, time, argparse
import mysql.connector

def load_env(path="infra/.env"):
    env = {}
    for line in open(path):
        line = line.strip()
        if line and "=" in line and not line.startswith("#"):
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip()
    return env

env = load_env()
conn = mysql.connector.connect(
    host="127.0.0.1", port=3307, user="root",
    password=env["MARIADB_ROOT_PASSWORD"], database="erp"
)
cur = conn.cursor()
cur.execute("SELECT customer_id FROM customers")
customers = [r[0] for r in cur.fetchall()]
cur.execute("SELECT item_id, standard_rate FROM items")
items = cur.fetchall()
cur.execute("SELECT warehouse_id FROM warehouses")
warehouses = [r[0] for r in cur.fetchall()]

parser = argparse.ArgumentParser()
parser.add_argument("--count", type=int, default=10)
parser.add_argument("--interval", type=int, default=3)
args = parser.parse_args()

for i in range(args.count):
    customer_id = random.choice(customers)
    item_id, rate = random.choice(items)
    warehouse_id = random.choice(warehouses)
    qty = random.randint(1, 5)
    amount = qty * float(rate)
    cur.execute("INSERT INTO sales_orders (customer_id, order_date) VALUES (%s, NOW(3))", (customer_id,))
    order_id = cur.lastrowid
    cur.execute(
        "INSERT INTO sales_order_lines (order_id, item_id, quantity, rate, amount) VALUES (%s, %s, %s, %s, %s)",
        (order_id, item_id, qty, rate, amount),
    )
    cur.execute(
        "INSERT INTO stock_ledger (item_id, warehouse_id, qty_change, voucher_type, voucher_id) VALUES (%s, %s, %s, 'SALES_ORDER', %s)",
        (item_id, warehouse_id, -qty, order_id),
    )
    cur.execute(
        "INSERT INTO gl_entries (account_code, debit, credit, voucher_type, voucher_id) VALUES ('RECEIVABLE', %s, 0, 'SALES_ORDER', %s)",
        (amount, order_id),
    )
    cur.execute(
        "INSERT INTO gl_entries (account_code, debit, credit, voucher_type, voucher_id) VALUES ('SALES', 0, %s, 'SALES_ORDER', %s)",
        (amount, order_id),
    )
    conn.commit()
    print(f"Order {order_id}: customer {customer_id}, item {item_id}, qty {qty}, amount {amount:.2f}")
    time.sleep(args.interval)

print("Done.")
