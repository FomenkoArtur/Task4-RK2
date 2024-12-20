CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE operations_log (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    operation VARCHAR(10) CHECK (operation IN ('ADD', 'REMOVE')),
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE update_stock(product_id INT, operation VARCHAR, quantity INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF operation = 'ADD' THEN
        UPDATE products
        SET quantity = quantity + quantity
        WHERE id = product_id;

        INSERT INTO operations_log (product_id, operation, quantity)
        VALUES (product_id, operation, quantity);

    ELSIF operation = 'REMOVE' THEN
	
        IF (SELECT quantity FROM products WHERE id = product_id) >= quantity THEN
		
            UPDATE products
            SET quantity = quantity - quantity
            WHERE id = product_id;

            INSERT INTO operations_log (product_id, operation, quantity)
            VALUES (product_id, operation, quantity);
        ELSE
            RAISE EXCEPTION 'Ошибка: количество списываемого товара больше, чем есть на складе';
        END IF;

    ELSE
        RAISE EXCEPTION 'Триггер: %', operation;
    END IF;
END;
$$;
