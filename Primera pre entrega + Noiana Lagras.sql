-- Creacion de la DB

DROP DATABASE IF EXISTS curso_sql; 
CREATE DATABASE curso_sql;
USE curso_sql;

-- Creacion de las tablas
CREATE TABLE Clientes (
  id_client INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  client_name VARCHAR(100) NOT NULL,
  dni VARCHAR(20) NOT NULL,
  birthdate DATE,
  client_mail VARCHAR(100) NOT NULL,
  client_address VARCHAR(150) NOT NULL,
  INDEX(client_name)
);

CREATE TABLE Metodos_de_Pago (
  id_pay INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  method VARCHAR(50) NOT NULL,
  INDEX(method)
);

CREATE TABLE Pedidos (
  id_order INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  buy_date DATE NOT NULL,
  id_client INT NOT NULL,
  id_pay INT NOT NULL,
  total_order DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (id_client) REFERENCES Clientes(id_client),
  FOREIGN KEY (id_pay) REFERENCES Metodos_de_Pago(id_pay)
);
CREATE TABLE Categorias(
id_categ INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
categ_name VARCHAR(30) NOT NULL,
INDEX (categ_name)
);
CREATE TABLE Productos (
  id_prod INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  prod_name VARCHAR(100) NOT NULL,
  list_price DECIMAL(10, 2) NOT NULL,
  wholesale_price DECIMAL(10, 2),
  retail_price DECIMAL(10, 2),
  prod_desc VARCHAR(255),
  id_categ INT,
  stock INT NOT NULL,
  thumbnails VARCHAR(260),
  FOREIGN KEY (id_categ) REFERENCES Categorias(id_categ),
  INDEX(prod_name, prod_desc)
);

CREATE TABLE Detalles_del_pedido (
    id_order INT,
    id_prod INT,
    prod_quantity INT NOT NULL,
    prod_price DECIMAL(10 , 2 ) NOT NULL,
    PRIMARY KEY (id_order , id_prod),
    FOREIGN KEY (id_order)
        REFERENCES Pedidos (id_order),
    FOREIGN KEY (id_prod)
        REFERENCES Productos (id_prod)
);
-- Insercion de datos en la tabla Clientes
INSERT INTO Clientes (client_name, dni, birthdate, client_mail, client_address)
VALUES 
  ('Juan Perez', '12345678', '1980-04-10', 'juanperez@mail.com', 'Calle 123'),
  ('Maria Gomez', '87654321', '1990-06-25', 'mariagomez@mail.com', 'Calle 456'),
  ('Carlos Martinez', '11223344', '1985-08-15', 'carlosmartinez@mail.com', 'Calle 789');

-- Inserción de datos en la tabla Metodos_de_Pago
INSERT INTO Metodos_de_Pago (method)
VALUES 
  ('Tarjeta de Credito'),
  ('Transferencia Bancaria'),
  ('Mercado Pago');

-- Insercion de datos en la tabla Categorias
INSERT INTO Categorias (categ_name)
VALUES 
  ('Ropa masculina'),
  ('Ropa femenina'),
  ('Buzos');

-- Insercion de datos en la tabla Productos
INSERT INTO Productos (prod_name, list_price, wholesale_price, retail_price, prod_desc, id_categ, stock, thumbnails)
VALUES 
  ('Buzo Addidas', 6000.00, 7000.00, 9000.00, 'Buzo addidas original', 3, 50, 'url_del_buzo'),
  ('Parka ', 200.00, 250.00, 280.00, 'Tapado de invierno ', 2, 200, 'url_del_tapado'),
  ('Camisa ', 3.000, 4.000, 4.500, 'Camisa blanca hombre',1 , 100, 'url_to_camisa');

-- Insercion de datos en la tabla Pedidos
INSERT INTO Pedidos (buy_date, id_client, id_pay, total_order)
VALUES 
  ('2024-01-10', 1, 1, 19500.00),  -- Juan Perez pago con tarjeta de credito
  ('2024-02-15', 2, 2, 6000.00),    -- Maria Gomez pago por transferencia bancaria
  ('2024-03-20', 3, 3, 4500.00);    -- Carlos Martinez pago por medio de mercado pago

-- Insercion de datos en la tabla Detalles_del_pedido
INSERT INTO Detalles_del_pedido (id_order, id_prod, prod_quantity, prod_price)
VALUES 
  (1, 1, 1, 9000.00),  -- Juan Perez compro 1 buzo addidas
  (1, 2, 5, 250.00),   -- Juan Perez tambien compro 5 parkas de mujer
  (2, 2, 2, 280.00),   -- Maria Gomez compro 2 parkas
  (3, 3, 10, 4000);   -- Carlos Martinez compro 10 camisas

-- CONSULTAS 


-- SELECT * FROM Clientes
-- SELECT * FROM Productos
 -- SELECT * FROM Pedidos probar total order 
-- SELECT * FROM Detalles_del_pedido
SELECT client_name, client_address
FROM Clientes
WHERE client_address = 'Calle 123';

SELECT prod_name, list_price
FROM Productos
ORDER BY list_price ASC;

-- Simplificar pedidos usando de alias p y en Clientes usado de alias c 
SELECT p.id_order, c.client_name, p.buy_date
FROM Pedidos AS p
JOIN Clientes AS c ON p.id_client = c.id_client;

-- Consulta de precios en caso de que no tenga precio mayorista 
SELECT prod_name, wholesale_price AS price
FROM Productos
WHERE wholesale_price IS NOT NULL
UNION
SELECT prod_name, retail_price AS price
FROM Productos
WHERE retail_price IS NOT NULL;

-- Consulta por productos con el  mayor precio
SELECT prod_name, list_price
FROM Productos
WHERE list_price = (SELECT MAX(list_price) FROM Productos);


-- Funcion para ver total gastado por el cliente de id 1
DELIMITER //

CREATE FUNCTION TotalGastadoPorCliente(client_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10, 2);


  SELECT SUM(total_order) INTO total
  FROM Pedidos
  WHERE id_client = client_id;

  RETURN total;
END //

DELIMITER ;
SELECT TotalGastadoPorCliente(1);


/*

DROP VIEW IF EXISTS Vista_Pedido;
CREATE VIEW Vista_Pedido AS
SELECT p.id_order, c.client_name, p.buy_date, p.total_order
FROM Pedidos p
JOIN Clientes c ON p.id_client = c.id_client;

SELECT * FROM Vista_Pedido;
*/
