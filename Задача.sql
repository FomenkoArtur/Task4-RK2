CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE operations_log (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    operation VARCHAR(10) CHECK (operation IN ('ADD', 'REMOVE')),
    quantity INTEGER NOT NULL
);

INSERT INTO products(id, name, quantity)
VALUES(1, 'rice', 5);
SELECT * FROM products;*/

CREATE OR REPLACE PROCEDURE update_stock(product_id INT, operation VARCHAR, quantit INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF operation = 'ADD' THEN
        UPDATE products
        SET quantity = products.quantity + quantit
        WHERE id = product_id;

        INSERT INTO operations_log (product_id, operation, quantity)
        VALUES (product_id, operation, quantit);

    ELSIF operation = 'REMOVE' THEN

        IF (SELECT products.quantity FROM products WHERE id = product_id) >= quantit THEN

            UPDATE products
            SET quantity = products.quantity - quantit
            WHERE id = product_id;

            INSERT INTO operations_log (product_id, operation, quantity)
            VALUES (product_id, operation, quantit);
        ELSE
            RAISE EXCEPTION 'Ошибка: количество списываемого товара больше, чем есть на складе';
        END IF;

    ELSE
        RAISE EXCEPTION 'Триггер: %', operation;
    END IF;
END;
$$;
CALL update_stock(1, 'REMOVE', 50);
CALL update_stock(1, 'ADD', 30);
SELECT * FROM products