-- ROL: Almacena los roles de los empleados.
CREATE TABLE Rol (
    Id_Rol NUMBER PRIMARY KEY,
    Nombre_Rol VARCHAR2(50)
);

-- CLIENTE: Almacena los datos de los clientes.
CREATE TABLE Cliente (
    Id_Clientes NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100),
    Telefono VARCHAR2(20),
    Direccion VARCHAR2(200)
);

-- METODOPAGO: Almacena los métodos de pago.
CREATE TABLE MetodoPago (
    Id_Metodo_Pago NUMBER PRIMARY KEY,
    Tipo_Pago VARCHAR2(50)
);

-- ESTADO_PEDIDO: Almacena los estados de los pedidos.
CREATE TABLE Estado_pedido (
    Id_Estado_Pedido NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(100)
);

-- TIPOPEDIDO: Almacena los tipos de pedidos.
CREATE TABLE TipoPedido (
    Id_Tipo_Pedido NUMBER PRIMARY KEY,
    Nombre_Tipo VARCHAR2(50),
    Descripcion VARCHAR2(200)
);

-- CATEGORIA: Almacena las categorías de productos.
CREATE TABLE Categoria (
    Id_Categoria NUMBER PRIMARY KEY,
    Nombre_Categoria VARCHAR2(100)
);

-- PROMOCION: Almacena las promociones disponibles.
CREATE TABLE Promocion (
    Id_Promocion NUMBER PRIMARY KEY,
    Nombre_Promocion VARCHAR2(100),
    Descripcion VARCHAR2(200),
    Porcentaje_Descuento NUMBER(5,2),
    Fecha_Inicio DATE,
    Fecha_Fin DATE,
    Estado VARCHAR2(30)
);

-- PROVEEDOR: Almacena los datos de los proveedores.
CREATE TABLE Proveedor (
    Id_Proveedor NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100),
    Telefono VARCHAR2(20),
    Direccion VARCHAR2(200)
);

-- COMBO: Almacena los combos disponibles.
CREATE TABLE Combo (
    Id_Combo NUMBER PRIMARY KEY,
    Nombre_Combo VARCHAR2(100),
    Precio NUMBER(10,2)
);

-- EMPLEADO: Almacena los empleados y sus roles.
CREATE TABLE Empleado (
    Id_Empleado NUMBER PRIMARY KEY,
    Id_Rol NUMBER,
    Nombre VARCHAR2(100),
    Telefono VARCHAR2(20),
    CONSTRAINT FK_Empleado_Rol
        FOREIGN KEY (Id_Rol) REFERENCES Rol(Id_Rol)
);

-- PRODUCTO: Almacena los productos y sus categorías.
CREATE TABLE Producto (
    Id_Producto NUMBER PRIMARY KEY,
    Id_Categoria NUMBER,
    Nombre VARCHAR2(100),
    Precio NUMBER(10,2),
    CONSTRAINT FK_Producto_Categoria
        FOREIGN KEY (Id_Categoria) REFERENCES Categoria(Id_Categoria)
);

-- VENTA: Almacena las ventas realizadas.
CREATE TABLE Venta (
    Id_Venta NUMBER PRIMARY KEY,
    Id_Cliente NUMBER,
    Id_Empleado NUMBER,
    Id_Metodo_Pago NUMBER,
    Fecha_Venta DATE,
    Total NUMBER(10,2),
    CONSTRAINT FK_Venta_Cliente
        FOREIGN KEY (Id_Cliente) REFERENCES Cliente(Id_Clientes),
    CONSTRAINT FK_Venta_Empleado
        FOREIGN KEY (Id_Empleado) REFERENCES Empleado(Id_Empleado),
    CONSTRAINT FK_Venta_Metodo
        FOREIGN KEY (Id_Metodo_Pago) REFERENCES MetodoPago(Id_Metodo_Pago)
);

-- PEDIDO: Almacena los pedidos realizados.
CREATE TABLE Pedido (
    Id_Pedido NUMBER PRIMARY KEY,
    Id_Cliente NUMBER,
    Id_Empleado NUMBER,
    Id_Estado_Pedido NUMBER,
    Id_Tipo_Pedido NUMBER,
    Fecha_Pedido DATE,
    CONSTRAINT FK_Pedido_Cliente
        FOREIGN KEY (Id_Cliente) REFERENCES Cliente(Id_Clientes),
    CONSTRAINT FK_Pedido_Empleado
        FOREIGN KEY (Id_Empleado) REFERENCES Empleado(Id_Empleado),
    CONSTRAINT FK_Pedido_Estado
        FOREIGN KEY (Id_Estado_Pedido) REFERENCES Estado_pedido(Id_Estado_Pedido),
    CONSTRAINT FK_Pedido_Tipo
        FOREIGN KEY (Id_Tipo_Pedido) REFERENCES TipoPedido(Id_Tipo_Pedido)
);

-- FACTURA: Almacena las facturas de las ventas.
CREATE TABLE Factura (
    Id_Factura NUMBER PRIMARY KEY,
    Id_Venta NUMBER,
    Numero_Factura VARCHAR2(50),
    Fecha_Factura DATE,
    Subtotal NUMBER(10,2),
    Impuesto NUMBER(10,2),
    Total NUMBER(10,2),
    CONSTRAINT FK_Factura_Venta
        FOREIGN KEY (Id_Venta) REFERENCES Venta(Id_Venta)
);

-- MESA: Almacena las mesas del establecimiento.
CREATE TABLE Mesa (
    Id_Mesa NUMBER PRIMARY KEY,
    Id_Pedido NUMBER,
    Numero_Mesa NUMBER,
    Capacidad NUMBER,
    Estado VARCHAR2(30),
    CONSTRAINT FK_Mesa_Pedido
        FOREIGN KEY (Id_Pedido) REFERENCES Pedido(Id_Pedido)
);

-- DETALLEVENTA: Almacena los productos de cada venta.
CREATE TABLE DetalleVenta (
    Id_DetalleVenta NUMBER PRIMARY KEY,
    Id_Venta NUMBER,
    Id_Producto NUMBER,
    Cantidad NUMBER,
    Subtotal NUMBER(10,2),
    CONSTRAINT FK_DVenta_Venta
        FOREIGN KEY (Id_Venta) REFERENCES Venta(Id_Venta),
    CONSTRAINT FK_DVenta_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto)
);

-- DETALLEPEDIDO: Almacena los productos de cada pedido.
CREATE TABLE DetallePedido (
    Id_Detalle_Pedido NUMBER PRIMARY KEY,
    Id_Pedido NUMBER,
    Id_Producto NUMBER,
    Cantidad NUMBER,
    Subtotal NUMBER(10,2),
    CONSTRAINT FK_DPedido_Pedido
        FOREIGN KEY (Id_Pedido) REFERENCES Pedido(Id_Pedido),
    CONSTRAINT FK_DPedido_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto)
);

-- ENTREGAPEDIDO: Almacena los datos de las entregas.
CREATE TABLE EntregaPedido (
    Id_Entrega NUMBER PRIMARY KEY,
    Id_Pedido NUMBER,
    Id_Empleado NUMBER,
    Direccion_Entrega VARCHAR2(200),
    Hora_entrega VARCHAR2(20),
    Estado_entrega VARCHAR2(30),
    CONSTRAINT FK_Entrega_Pedido
        FOREIGN KEY (Id_Pedido) REFERENCES Pedido(Id_Pedido),
    CONSTRAINT FK_Entrega_Empleado
        FOREIGN KEY (Id_Empleado) REFERENCES Empleado(Id_Empleado)
);

-- INVENTARIO: Almacena las cantidades disponibles de productos.
CREATE TABLE Inventario (
    Id_Inventario NUMBER PRIMARY KEY,
    Id_Producto NUMBER,
    Cantidad_Disponible NUMBER,
    Fecha_Actualizacion DATE,
    CONSTRAINT FK_Inventario_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto)
);

-- MOVIMIENTOINVENTARIO: Registra entradas y salidas de productos.
CREATE TABLE MovimientoInventario (
    Id_Movimiento NUMBER PRIMARY KEY,
    Id_Producto NUMBER,
    Id_Empleado NUMBER,
    Tipo_Movimiento VARCHAR2(50),
    Cantidad NUMBER,
    Fecha_Movimiento DATE,
    Descripcion VARCHAR2(200),
    CONSTRAINT FK_Mov_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto),
    CONSTRAINT FK_Mov_Empleado
        FOREIGN KEY (Id_Empleado) REFERENCES Empleado(Id_Empleado)
);

-- TURNOEMPLEADO: Almacena los turnos de los empleados.
CREATE TABLE TurnoEmpleado (
    Id_turno NUMBER PRIMARY KEY,
    Id_Empleado NUMBER,
    Fecha DATE,
    Hora_inicio VARCHAR2(20),
    Hora_fin VARCHAR2(20),
    Estado VARCHAR2(30),
    CONSTRAINT FK_Turno_Empleado
        FOREIGN KEY (Id_Empleado) REFERENCES Empleado(Id_Empleado)
);

-- PRODUCTOPROMOCION: Relaciona productos con promociones.
CREATE TABLE ProductoPromocion (
    Id_Producto_Promocion NUMBER PRIMARY KEY,
    Id_Producto NUMBER,
    Id_Promocion NUMBER,
    CONSTRAINT FK_ProdProm_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto),
    CONSTRAINT FK_ProdProm_Promocion
        FOREIGN KEY (Id_Promocion) REFERENCES Promocion(Id_Promocion)
);

-- DETALLECOMBO: Almacena los productos de cada combo.
CREATE TABLE DetalleCombo (
    Id_Detalle_Combo NUMBER PRIMARY KEY,
    Id_Combo NUMBER,
    Id_Producto NUMBER,
    Cantidad NUMBER,
    CONSTRAINT FK_DCombo_Combo
        FOREIGN KEY (Id_Combo) REFERENCES Combo(Id_Combo),
    CONSTRAINT FK_DCombo_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto)
);

-- COMPRA: Almacena las compras realizadas a proveedores.
CREATE TABLE Compra (
    Id_Compra NUMBER PRIMARY KEY,
    Id_Proveedor NUMBER,
    Fecha_Compra DATE,
    Total NUMBER(10,2),
    CONSTRAINT FK_Compra_Proveedor
        FOREIGN KEY (Id_Proveedor) REFERENCES Proveedor(Id_Proveedor)
);

-- DETALLECOMPRA: Almacena los productos de cada compra.
CREATE TABLE DetalleCompra (
    Id_Detalle_Compra NUMBER PRIMARY KEY,
    Id_Compra NUMBER,
    Id_Producto NUMBER,
    Cantidad NUMBER,
    Precio_Compra NUMBER(10,2),
    CONSTRAINT FK_DCompra_Compra
        FOREIGN KEY (Id_Compra) REFERENCES Compra(Id_Compra),
    CONSTRAINT FK_DCompra_Producto
        FOREIGN KEY (Id_Producto) REFERENCES Producto(Id_Producto)
);

-- DATOS DE PRUEBA

INSERT INTO Rol VALUES (1, 'Administrador');
INSERT INTO Rol VALUES (2, 'Cajero');
INSERT INTO Rol VALUES (3, 'Mesero');

INSERT INTO Cliente VALUES (1, 'Carlos Ramirez', '88881111', 'Heredia');
INSERT INTO Cliente VALUES (2, 'Maria Fernandez', '87772222', 'San Jose');

INSERT INTO MetodoPago VALUES (1, 'Efectivo');
INSERT INTO MetodoPago VALUES (2, 'Tarjeta');
INSERT INTO MetodoPago VALUES (3, 'SINPE Movil');

INSERT INTO Estado_pedido VALUES (1, 'Pendiente');
INSERT INTO Estado_pedido VALUES (2, 'En preparacion');
INSERT INTO Estado_pedido VALUES (3, 'Entregado');

INSERT INTO TipoPedido VALUES (1, 'Local', 'Consumo en el establecimiento');
INSERT INTO TipoPedido VALUES (2, 'Express', 'Entrega a domicilio');
INSERT INTO TipoPedido VALUES (3, 'Para llevar', 'Pedido para retirar');

INSERT INTO Categoria VALUES (1, 'Bebidas');
INSERT INTO Categoria VALUES (2, 'Comidas');
INSERT INTO Categoria VALUES (3, 'Postres');

INSERT INTO Promocion VALUES (
    1, 'Descuento especial', 'Descuento de prueba',
    10, DATE '2026-01-01', DATE '2026-12-31', 'Activa'
);

INSERT INTO Proveedor VALUES (1, 'Distribuidora Central', '22223333', 'San Jose');
INSERT INTO Proveedor VALUES (2, 'Alimentos del Valle', '22224444', 'Heredia');

INSERT INTO Combo VALUES (1, 'Combo Familiar', 8500);
INSERT INTO Combo VALUES (2, 'Combo Individual', 4500);

INSERT INTO Empleado VALUES (1, 1, 'Juan Perez', '88880001');
INSERT INTO Empleado VALUES (2, 2, 'Ana Lopez', '88880002');
INSERT INTO Empleado VALUES (3, 3, 'Pedro Mora', '88880003');

INSERT INTO Producto VALUES (1, 1, 'Gaseosa', 1000);
INSERT INTO Producto VALUES (2, 2, 'Hamburguesa', 3500);
INSERT INTO Producto VALUES (3, 3, 'Queque', 1500);

INSERT INTO Venta VALUES (1, 1, 2, 1, DATE '2026-11-01', 4500);
INSERT INTO Venta VALUES (2, 2, 2, 2, DATE '2026-11-02', 5000);

INSERT INTO DetalleVenta VALUES (1, 1, 1, 1, 1000);
INSERT INTO DetalleVenta VALUES (2, 1, 2, 1, 3500);
INSERT INTO DetalleVenta VALUES (3, 2, 3, 1, 1500);

INSERT INTO Factura VALUES (
    1, 1, 'FAC-001', DATE '2026-11-01', 3982.30, 517.70, 4500
);

INSERT INTO Factura VALUES (
    2, 2, 'FAC-002', DATE '2026-11-02', 4424.78, 575.22, 5000
);

INSERT INTO Pedido VALUES (1, 1, 3, 3, 1, DATE '2026-11-03');
INSERT INTO Pedido VALUES (2, 2, 3, 1, 2, DATE '2026-11-04');

INSERT INTO Mesa VALUES (1, 1, 5, 4, 'Ocupada');

INSERT INTO DetallePedido VALUES (1, 1, 2, 2, 7000);
INSERT INTO DetallePedido VALUES (2, 2, 1, 3, 3000);

INSERT INTO EntregaPedido VALUES (
    1, 2, 3, 'Heredia Centro', '12:30', 'Pendiente'
);

INSERT INTO Inventario VALUES (1, 1, 100, DATE '2026-11-01');
INSERT INTO Inventario VALUES (2, 2, 50, DATE '2026-11-01');
INSERT INTO Inventario VALUES (3, 3, 30, DATE '2026-11-01');

INSERT INTO MovimientoInventario VALUES (
    1, 1, 1, 'Entrada', 50, DATE '2026-11-01', 'Compra de gaseosas'
);

INSERT INTO MovimientoInventario VALUES (
    2, 2, 1, 'Salida', 5, DATE '2026-11-02', 'Salida por ventas'
);

INSERT INTO TurnoEmpleado VALUES (
    1, 1, DATE '2026-11-01', '08:00', '16:00', 'Completado'
);

INSERT INTO TurnoEmpleado VALUES (
    2, 2, DATE '2026-11-01', '09:00', '17:00', 'Completado'
);

INSERT INTO ProductoPromocion VALUES (1, 1, 1);
INSERT INTO ProductoPromocion VALUES (2, 2, 1);

INSERT INTO DetalleCombo VALUES (1, 1, 1, 2);
INSERT INTO DetalleCombo VALUES (2, 1, 2, 2);
INSERT INTO DetalleCombo VALUES (3, 2, 2, 1);
INSERT INTO DetalleCombo VALUES (4, 2, 1, 1);

INSERT INTO Compra VALUES (1, 1, DATE '2026-11-01', 50000);
INSERT INTO Compra VALUES (2, 2, DATE '2026-11-02', 30000);

INSERT INTO DetalleCompra VALUES (1, 1, 1, 50, 500);
INSERT INTO DetalleCompra VALUES (2, 1, 2, 20, 2000);
INSERT INTO DetalleCompra VALUES (3, 2, 3, 20, 1000);

COMMIT;

-- COMPROBAR TABLAS CREADAS
SELECT TABLE_NAME
FROM USER_TABLES
ORDER BY TABLE_NAME;

-- COMPROBAR CLAVES PRIMARIAS
SELECT TABLE_NAME, CONSTRAINT_NAME
FROM USER_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'P'
ORDER BY TABLE_NAME;

-- COMPROBAR CLAVES FORANEAS
SELECT TABLE_NAME, CONSTRAINT_NAME, R_CONSTRAINT_NAME
FROM USER_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'R'
ORDER BY TABLE_NAME;

-- COMPROBAR DATOS INSERTADOS
SELECT * FROM Cliente;
SELECT * FROM Empleado;
SELECT * FROM Producto;
SELECT * FROM Venta;
SELECT * FROM DetalleVenta;
SELECT * FROM Factura;
SELECT * FROM Pedido;
SELECT * FROM DetallePedido;
SELECT * FROM Inventario;
SELECT * FROM Compra;
SELECT * FROM DetalleCompra;

-- COMPROBAR RELACION ENTRE VENTAS, CLIENTES Y EMPLEADOS
SELECT
    V.Id_Venta,
    C.Nombre AS Cliente,
    E.Nombre AS Empleado,
    M.Tipo_Pago,
    V.Fecha_Venta,
    V.Total
FROM Venta V
INNER JOIN Cliente C ON V.Id_Cliente = C.Id_Clientes
INNER JOIN Empleado E ON V.Id_Empleado = E.Id_Empleado
INNER JOIN MetodoPago M ON V.Id_Metodo_Pago = M.Id_Metodo_Pago;

-- COMPROBAR RELACION ENTRE DETALLES DE VENTA Y PRODUCTOS
SELECT
    DV.Id_DetalleVenta,
    V.Id_Venta,
    P.Nombre AS Producto,
    DV.Cantidad,
    DV.Subtotal
FROM DetalleVenta DV
INNER JOIN Venta V ON DV.Id_Venta = V.Id_Venta
INNER JOIN Producto P ON DV.Id_Producto = P.Id_Producto;

-- COMPROBAR RELACION ENTRE PEDIDOS Y CLIENTES
SELECT
    P.Id_Pedido,
    C.Nombre AS Cliente,
    E.Nombre AS Empleado,
    EP.Descripcion AS Estado,
    TP.Nombre_Tipo AS Tipo_Pedido,
    P.Fecha_Pedido
FROM Pedido P
INNER JOIN Cliente C ON P.Id_Cliente = C.Id_Clientes
INNER JOIN Empleado E ON P.Id_Empleado = E.Id_Empleado
INNER JOIN Estado_pedido EP ON P.Id_Estado_Pedido = EP.Id_Estado_Pedido
INNER JOIN TipoPedido TP ON P.Id_Tipo_Pedido = TP.Id_Tipo_Pedido;

-- COMPROBAR RELACION ENTRE PRODUCTOS Y CATEGORIAS
SELECT
    P.Id_Producto,
    P.Nombre,
    P.Precio,
    C.Nombre_Categoria
FROM Producto P
INNER JOIN Categoria C ON P.Id_Categoria = C.Id_Categoria;

-- COMPROBAR RELACION ENTRE COMPRAS Y PROVEEDORES
SELECT
    C.Id_Compra,
    P.Nombre AS Proveedor,
    C.Fecha_Compra,
    C.Total
FROM Compra C
INNER JOIN Proveedor P ON C.Id_Proveedor = P.Id_Proveedor;

-- COMPROBAR RELACION ENTRE INVENTARIO Y PRODUCTOS
SELECT
    I.Id_Inventario,
    P.Nombre AS Producto,
    I.Cantidad_Disponible,
    I.Fecha_Actualizacion
FROM Inventario I
INNER JOIN Producto P ON I.Id_Producto = P.Id_Producto;

select * from CLIENTE;