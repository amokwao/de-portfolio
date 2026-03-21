-- Insert
INSERT INTO retail.orders (customer_id, status, total) VALUES (1, 'NEW', 300);

-- Update
UPDATE retail.orders SET status='SHIPPED' WHERE order_id=1;

-- Delete
DELETE FROM retail.orders WHERE order_id=2;