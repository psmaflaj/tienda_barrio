-- presentado por:
-- Pedro Santiago Mafla Jaramillo
USE tienda_barrio;

CREATE TABLE IF NOT EXISTS Clientes (
    ID_Cliente INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20),
    Direccion VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS Proveedores (
    ID_Proveedor INT PRIMARY KEY AUTO_INCREMENT,
    Nombre_Proveedor VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20),
    Direccion VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS Productos (
    ID_Producto INT PRIMARY KEY AUTO_INCREMENT,
    Nombre_Producto VARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    ID_Proveedor INT,
    FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor)
);

CREATE TABLE IF NOT EXISTS Ventas (
    ID_Venta INT PRIMARY KEY AUTO_INCREMENT,
    ID_Cliente INT,
    Fecha_Venta DATE NOT NULL,
    Total DECIMAL(10, 2),
    FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID_Cliente)
);

CREATE TABLE IF NOT EXISTS Detalle_Venta (
    ID_Detalle INT PRIMARY KEY AUTO_INCREMENT,
    ID_Venta INT,
    ID_Producto INT,
    Cantidad INT NOT NULL,
    Subtotal DECIMAL(10, 2),
    FOREIGN KEY (ID_Venta) REFERENCES Ventas(ID_Venta),
    FOREIGN KEY (ID_Producto) REFERENCES Productos(ID_Producto)
);
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS RegistrarVenta(
    IN p_ID_Cliente INT,
    IN p_Fecha_Venta DATE,
    IN p_Total DECIMAL(10, 2),
    IN p_ID_Producto INT,
    IN p_Cantidad INT
)
BEGIN
    DECLARE v_ID_Venta INT;
    DECLARE v_Subtotal DECIMAL(10, 2);

    -- Calcular el subtotal
    SET v_Subtotal = (SELECT Precio FROM Productos WHERE ID_Producto = p_ID_Producto) * p_Cantidad;

    -- Inserts
    INSERT INTO Ventas (ID_Cliente, Fecha_Venta, Total) 
    VALUES (p_ID_Cliente, p_Fecha_Venta, p_Total);
   
    SET v_ID_Venta = LAST_INSERT_ID();

    INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal) 
    VALUES (v_ID_Venta, p_ID_Producto, p_Cantidad, v_Subtotal);

    -- Actualizar el stock del producto
    UPDATE Productos 
    SET Stock = Stock - p_Cantidad 
    WHERE ID_Producto = p_ID_Producto;

    -- Mostrar dicha venta registrada con detalle
    SELECT v.ID_Venta, v.Fecha_Venta, v.Total, c.Nombre AS Cliente
    FROM Ventas v
    INNER JOIN Clientes c ON v.ID_Cliente = c.ID_Cliente
    WHERE v.ID_Venta = v_ID_Venta;

    SELECT dv.ID_Detalle, dv.ID_Venta, p.Nombre_Producto, dv.Cantidad, dv.Subtotal
    FROM Detalle_Venta dv
    INNER JOIN Productos p ON dv.ID_Producto = p.ID_Producto
    WHERE dv.ID_Venta = v_ID_Venta;
END$$

DELIMITER ;

-- función para calcular el total de ventas de un cliente
DELIMITER $$

DROP FUNCTION IF EXISTS TotalVentasCliente;

CREATE FUNCTION TotalVentasCliente(p_ID_Cliente INT) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);

    SELECT SUM(Total) INTO total
    FROM Ventas
    WHERE ID_Cliente = p_ID_Cliente;

    RETURN IFNULL(total, 0);
END;


DELIMITER ;
