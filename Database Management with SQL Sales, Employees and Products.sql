-- Create Database
create database tpGestion;
-- Use the created database
use tpGestion;

-- Create the sales table
CREATE TABLE  ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATE,
    monto DECIMAL(10, 2)
);

-- Insert test data
INSERT INTO ventas (fecha_venta, monto) VALUES
('2023-07-01', 100.50),
('2023-07-15', 200.75),
('2023-08-05', 150.00),
('2023-08-20', 300.25),
('2023-09-10', 250.00);

-- Function to calculate total sales by month
delimiter //
create function calcular_total_ventas (mes int, ano  int)
returns decimal (10,2)
deterministic
begin
     declare total decimal(10,2);
     
     -- Calculate total sales
     select ifnull(sum(monto),0) into total
     from ventas
     where month(fecha_venta)= mes and year(fecha_venta)= ano;
     return total;
end
// 
delimiter ;

-- Function test
SELECT calcular_total_ventas(7, 2023) AS total_ventas_julio_2023;
SELECT calcular_total_ventas(8, 2023) AS total_ventas_agosto_2023;
SELECT calcular_total_ventas(9, 2023) AS total_ventas_septiembre_2023;

-- Create the employees table
CREATE TABLE IF NOT EXISTS empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50)
);

-- Insert test data 
INSERT INTO empleados (nombre, apellido) VALUES
('Juan', 'Pérez'),
('María', 'Gómez'),
('Pedro', 'López'),
('Ana', 'Martínez');

-- Function to get full name of employee
delimiter //
create function obtener_nombre_empleado(e_id int)
returns nvarchar(100)
deterministic
begin
  declare nombre_completo nvarchar(100);
   -- Operation to get the full name
   select concat(nombre,' ', apellido) into nombre_completo
   from empleados
   where id=e_id;
   
   return nombre_completo;
end
//  
delimiter ;

-- Function test 
SELECT obtener_nombre_empleado(1) AS nombre_completo_empleado;
SELECT obtener_nombre_empleado(2) AS nombre_completo_empleado;
SELECT obtener_nombre_empleado(3) AS nombre_completo_empleado;
SELECT obtener_nombre_empleado(4) AS nombre_completo_empleado;

-- Create the courses table
CREATE TABLE IF NOT EXISTS cursos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alumno VARCHAR(100),
    curso VARCHAR(100),
    calificacion DECIMAL(5, 2)
);

-- Insert test data
INSERT INTO cursos (alumno, curso, calificacion) VALUES
('Carlos Pérez', 'Matemáticas', 85.50),
('Ana Gómez', 'Matemáticas', 90.00),
('Juan López', 'Matemáticas', 78.75),
('Ana Gómez', 'Historia', 88.00),
('María Fernández', 'Historia', 92.50),
('Carlos Pérez', 'Biología', 75.00),
('Juan López', 'Biología', 82.00);

-- Procedure to calculate average grade for a course
delimiter //
create procedure obtener_promedio (in nombre nvarchar(100))
begin 
    declare promedio decimal(5,2);
    
    -- Calculate the average grade
    select avg(calificacion) into promedio
    from cursos
    where cursos = nombre;
    
    select promedio as promedio_calificaciones;
end
// delimiter ;

-- Procedure test
CALL obtener_promedio('Matemáticas');
CALL obtener_promedio('Historia');
CALL obtener_promedio('Biología');

-- Create the products table 
CREATE TABLE IF NOT EXISTS productos (
    codigo_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100),
    stock_actual INT
);

-- Insert test data
INSERT INTO productos (codigo_producto, nombre_producto, stock_actual) VALUES
(1, 'Producto A', 50),
(2, 'Producto B', 30),
(3, 'Producto C', 20);

-- Procedure to update product stock
delimiter //
create procedure actualizar_stock (
in p_codigo_producto int,
in p_cant_agregar int)
begin 
-- Check if the product exists
  if exists (select 1 from productos where codigo_producto = p_codigo_producto) then
  -- Update stock
   update productos
   set stock_actual = stock_actual + p_cant_agregar
   where  codigo_producto = p_codigo_producto;
   else
   -- Show error if product does not exist
    select concat( 'The product with code ', p_codigo_producto, ' does not exist.') AS error_message;
    END IF; 
end
// delimiter ;

-- Procedure test
SELECT * FROM productos;
CALL actualizar_stock(1, 10);
SELECT * FROM productos;
CALL actualizar_stock(4, 5);

-- 5

USE pubs;

CREATE VIEW vista_libros_cocina AS
SELECT 
    t.title AS title,
    CONCAT(a.au_fname, ' ', a.au_lname) AS author,
    t.price AS price,
    p.pub_name AS publisher
FROM 
    titles t
JOIN 
    publishers p ON t.pub_id = p.pub_id
JOIN 
    titleauthor ta ON t.title_id = ta.title_id
JOIN 
    authors a ON ta.au_id = a.au_id
WHERE 
    t.type in('mod_cook','trad_cook');
    
-- Show view
select * from vista_libros_cocina;

-- 6
CREATE TABLE fabricantes (
    id_fabricante INT PRIMARY KEY,
    nombre_fabricante VARCHAR(255) NOT NULL
);

INSERT INTO fabricantes (id_fabricante, nombre_fabricante)
VALUES(1, 'Fabricante A'),(2, 'Fabricante B'),(3, 'Fabricante C');

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    id_fabricante INT,
    nombre_producto VARCHAR(255) NOT NULL,
    fecha_lanzamiento DATE,
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante)
);

INSERT INTO productos (id_producto, id_fabricante, nombre_producto, fecha_lanzamiento)
VALUES(1, 1, 'Producto X', '2020-01-01'),(2, 2, 'Producto Y', '2019-12-01'), (3, 3, 'Producto Z', '2021-05-15');

-- a
CREATE INDEX idx_productos_id_fabricante_nombre 
ON productos (id_fabricante, nombre_producto);

-- b
CREATE UNIQUE INDEX idx_unico_id_producto 
ON productos (id_producto);

-- c
DROP INDEX idx_productos_id_fabricante_nombre 
ON productos;

-- Create new unique index on id_fabricante and nombre_producto
CREATE UNIQUE INDEX idx_unico_id_fabricante_nombre 
ON productos (id_fabricante, nombre_producto);

-- d
CREATE UNIQUE INDEX idx_unico_id_fabricante 
ON productos (id_fabricante);

-- e
DROP INDEX idx_productos_id_fabricante 
ON productos;

-- 7

CREATE TABLE  empleados (
    nombre VARCHAR(50) NOT NULL,
    edad INT NOT NULL,
    antiguedad INT NOT NULL
);

CREATE TABLE  jubilados (
    nombre VARCHAR(50) NOT NULL,
    edad INT NOT NULL,
    antiguedad INT NOT NULL
);

delimiter //
create trigger transferir_a_jubilados
after insert on empleados
for each row
begin 
    -- Check if it meets the criteria
    if new.antiguedad >= 30 and new.edad >= 65 then
    -- Insert into jubilados table
    insert into jubilados (nombre,edad,antiguedad) values
    (new.nombre,new.edad,new.antiguedad);
    end if;
end
// delimiter ;

-- Test
INSERT INTO empleados (nombre, edad, antiguedad)
VALUES ('Juan Perez', 66, 31), ('Ana Lopez', 55, 20), ('Carlos Ruiz', 70, 35);

SELECT * FROM jubilados;

-- 8
CREATE TABLE IF NOT EXISTS empleados (
    codigo_empleado VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50),
    salario DECIMAL(10, 2)
);

-- Insert test data
INSERT INTO empleados (codigo_empleado, nombre, salario)
VALUES ('E001', 'Juan Perez', 5000.00),
       ('E002', 'Ana Lopez', 6000.00),
       ('E003', 'Carlos Ruiz', 7000.00);

delimiter //
create procedure actualizar_empleados(
in codigo_empleado varchar(10),
in salario_actualizado decimal(10,2))
begin 
declare salario_actual decimal(10,2);
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK; 
        SELECT 'An error occurred. The transaction has been rolled back.' AS error_message;
    END;
    start transaction;
    -- Get current salary
        SELECT salario INTO salario_actual
    FROM empleados
    WHERE codigo_empleado = codigo_empleado;
      -- Verify if the new salary is valid
    IF salario_actualizado < salario_actual THEN
        SELECT 'The new salary cannot be less than the current salary. Operation canceled.' AS message;
        ROLLBACK;
    ELSE
        -- Update employee salary
        UPDATE empleados
        SET salario = salario_actualizado
        WHERE codigo_empleado = codigo_empleado;
        COMMIT;
        SELECT 'The salary has been successfully updated.' AS message;
    END IF;
END
// delimiter ;       
-- Test cases
-- Test case: updated salary greater than the current salary
CALL ActualizarEmpleados('E001', 5500.00);
SELECT * FROM empleados WHERE codigo_empleado = 'E001';

-- Test case: updated salary less than the current salary
CALL ActualizarEmpleados('E002', 5500.00);
SELECT * FROM empleados WHERE codigo_empleado = 'E002';

-- Test case: updated salary equals the current salary
CALL ActualizarEmpleados('E003', 7000.00);
SELECT * FROM empleados WHERE codigo_empleado = 'E003';


-- a
create user 'pepe'@'localhost' identified by '1234';
-- b
create user 'juan'@'localhost' identified by '5678';
grant select on pubs.* to 'juan'@'localhost';

-- c
create user 'raul'@'localhost' identified by '2022';
grant update,insert,delete on pubs.* to 'raul'@'localhost';

-- d
create user 'maria'@'localhost' identified by  '2023';
grant all privileges on pubs.* to 'maria'@'localhost';

-- e
create user 'messi'@'localhost' identified by  '2024';
grant select on pubs.titles to 'messi'@'localhost';

-- f
drop user 'maria'@'localhost';

-- g
create user 'juan'@'localhost','pepe'@'localhost';

-- h
drop user 'raul'@'localhost';

-- i
show grants for 'messi'@'localhost';
