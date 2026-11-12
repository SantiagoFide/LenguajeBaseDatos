-- 02. Programación de Comida Rápida EVY
-- SET DEFINE OFF desactiva la sustitución de variables con ampersand.
SET DEFINE OFF

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- 1. SECUENCIAS PARA LOS IDENTIFICADORES
-- Se parte del mayor ID existente y luego Oracle asigna IDs con secuencias
DECLARE
    -- Recibe el nombre de la tabla y el de su columna de ID.
    PROCEDURE crear_secuencia(p_tabla VARCHAR2, p_columna VARCHAR2) IS
        v_inicio NUMBER;
        v_existe NUMBER;
    BEGIN
        -- USER_SEQUENCES lista las secuencias que pertenecen al esquema actual.
        SELECT COUNT(*) INTO v_existe
        FROM user_sequences WHERE sequence_name = 'SEQ_' || UPPER(p_tabla);
        IF v_existe = 0 THEN
            -- Calcula el mayor ID + 1. Si no hay filas, empieza en 1.
            -- EXECUTE IMMEDIATE permite usar los nombres de tabla y columna recibidos.
            EXECUTE IMMEDIATE 'SELECT GREATEST(NVL(MAX(' || p_columna ||
                '), 0), 0) + 1 FROM ' || p_tabla INTO v_inicio;
            -- Crea la secuencia solo cuando no existe. NOCYCLE evita que vuelva al inicio.
            EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_' || p_tabla ||
                ' START WITH ' || TO_CHAR(v_inicio, 'TM9') || ' NOCYCLE';
        END IF;
    END;
BEGIN

    crear_secuencia('Cliente', 'Id_Clientes');

    crear_secuencia('Empleado', 'Id_Empleado');

    crear_secuencia('Producto', 'Id_Producto');

    crear_secuencia('Pedido', 'Id_Pedido');

    crear_secuencia('Venta', 'Id_Venta');

    crear_secuencia('Inventario', 'Id_Inventario');

END;
/

-- 2. FUNCIONES
-- Suma los subtotales de los detalles de una venta. NVL devuelve 0 si SUM da NULL.
CREATE OR REPLACE FUNCTION subtotal_venta(p_id Venta.Id_Venta%TYPE)
RETURN NUMBER IS
    v_subtotal NUMBER;
BEGIN
    SELECT NVL(SUM(Subtotal), 0) INTO v_subtotal
    FROM DetalleVenta WHERE Id_Venta = p_id;
    RETURN v_subtotal;
END;
/

-- Suma el total registrado de todas las ventas y devuelve 0 si no hay montos.
CREATE OR REPLACE FUNCTION total_ventas RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(Total), 0) INTO v_total FROM Venta;
    RETURN v_total;
END;
/

-- 3. TRIGGERS
-- Valida el precio por fila antes de insertar un producto o actualizar su precio
CREATE OR REPLACE TRIGGER trg_precio_producto
BEFORE INSERT OR UPDATE OF Precio ON Producto
FOR EACH ROW
BEGIN
    IF :NEW.Precio IS NULL OR :NEW.Precio < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El precio debe ser mayor o igual a cero.');
    END IF;
END;
/

-- Valida la cantidad y guarda la fecha actual en cada inserción o modificación de inventario.
CREATE OR REPLACE TRIGGER trg_actualiza_inventario
BEFORE INSERT OR UPDATE ON Inventario
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad_Disponible IS NULL OR :NEW.Cantidad_Disponible < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'La cantidad debe ser mayor o igual a cero.');
    END IF;
    :NEW.Fecha_Actualizacion := SYSDATE;
END;
/

-- 4. VISTAS
-- Lista los datos de contacto de cada cliente.
CREATE OR REPLACE VIEW vw_evy_Cliente AS
SELECT t.Id_Clientes,
       t.Nombre,
       t.Telefono,
       t.Direccion
FROM Cliente t;

-- Muestra cada empleado junto con el nombre de su rol.
CREATE OR REPLACE VIEW vw_evy_Empleado AS
SELECT t.Id_Empleado,
       t.Id_Rol,
       t.Nombre,
       t.Telefono,
       j1.Nombre_Rol AS Nombre_Rol
FROM Empleado t 
LEFT JOIN Rol j1 ON j1.Id_Rol = t.Id_Rol;

-- Muestra nombre, precio y categoría de cada producto.
CREATE OR REPLACE VIEW vw_evy_Producto AS
SELECT t.Id_Producto,
       t.Id_Categoria,
       t.Nombre,
       t.Precio,
       j1.Nombre_Categoria AS Nombre_Categoria
FROM Producto t 
LEFT JOIN Categoria j1 ON j1.Id_Categoria = t.Id_Categoria;

-- Combina el pedido con su cliente, empleado, estado y tipo.
CREATE OR REPLACE VIEW vw_evy_Pedido AS
SELECT t.Id_Pedido,
       t.Id_Cliente,
       t.Id_Empleado,
       t.Id_Estado_Pedido,
       t.Id_Tipo_Pedido,
       j1.Nombre AS Cliente,
       j2.Nombre AS Empleado,
       j3.Descripcion AS Descripcion,
       j4.Nombre_Tipo AS Nombre_Tipo,
       TO_CHAR(t.Fecha_Pedido, 'YYYY-MM-DD HH24:MI') AS Fecha_Pedido
FROM Pedido t 
LEFT JOIN Cliente j1 ON j1.Id_Clientes = t.Id_Cliente
LEFT JOIN Empleado j2 ON j2.Id_Empleado = t.Id_Empleado
LEFT JOIN Estado_pedido j3 ON j3.Id_Estado_Pedido = t.Id_Estado_Pedido
LEFT JOIN TipoPedido j4 ON j4.Id_Tipo_Pedido = t.Id_Tipo_Pedido;

-- Combina la venta con cliente, empleado y medio de pago. Distingue el total registrado del subtotal calculado desde los detalles.
CREATE OR REPLACE VIEW vw_evy_Venta AS
SELECT t.Id_Venta,
       t.Id_Cliente,
       t.Id_Empleado,
       t.Id_Metodo_Pago,
       t.Total,
       j1.Nombre AS Cliente,
       j2.Nombre AS Empleado,
       j3.Tipo_Pago AS Tipo_Pago,
       TO_CHAR(t.Fecha_Venta, 'YYYY-MM-DD HH24:MI') AS Fecha_Venta,
       subtotal_venta(t.Id_Venta) AS Subtotal_Detalle
FROM Venta t 
LEFT JOIN Cliente j1 ON j1.Id_Clientes = t.Id_Cliente
LEFT JOIN Empleado j2 ON j2.Id_Empleado = t.Id_Empleado
LEFT JOIN MetodoPago j3 ON j3.Id_Metodo_Pago = t.Id_Metodo_Pago;

-- Muestra las existencias, el nombre del producto y la fecha de actualización.
CREATE OR REPLACE VIEW vw_evy_Inventario AS
SELECT t.Id_Inventario,
       t.Id_Producto,
       t.Cantidad_Disponible,
       j1.Nombre AS Producto,
       TO_CHAR(t.Fecha_Actualizacion, 'YYYY-MM-DD HH24:MI') AS Fecha_Actualizacion
FROM Inventario t 
LEFT JOIN Producto j1 ON j1.Id_Producto = t.Id_Producto;

-- 5. ESPECIFICACIÓN DEL PAQUETE
-- Declara los procedimientos públicos, sus parámetros y los valores que devuelven.
CREATE OR REPLACE PACKAGE pkg_evy AS
    PROCEDURE registrar_Cliente(p_Nombre Cliente.Nombre%TYPE, p_Telefono Cliente.Telefono%TYPE, p_Direccion Cliente.Direccion%TYPE, p_id OUT Cliente.Id_Clientes%TYPE);
    PROCEDURE consultar_Cliente(p_filas OUT SYS_REFCURSOR);
    PROCEDURE modificar_Cliente(p_id Cliente.Id_Clientes%TYPE, p_Nombre Cliente.Nombre%TYPE, p_Telefono Cliente.Telefono%TYPE, p_Direccion Cliente.Direccion%TYPE);
    PROCEDURE eliminar_Cliente(p_id Cliente.Id_Clientes%TYPE);
    PROCEDURE registrar_Empleado(p_Id_Rol Empleado.Id_Rol%TYPE, p_Nombre Empleado.Nombre%TYPE, p_Telefono Empleado.Telefono%TYPE, p_id OUT Empleado.Id_Empleado%TYPE);
    PROCEDURE consultar_Empleado(p_filas OUT SYS_REFCURSOR);
    PROCEDURE modificar_Empleado(p_id Empleado.Id_Empleado%TYPE, p_Id_Rol Empleado.Id_Rol%TYPE, p_Nombre Empleado.Nombre%TYPE, p_Telefono Empleado.Telefono%TYPE);
    PROCEDURE eliminar_Empleado(p_id Empleado.Id_Empleado%TYPE);
    PROCEDURE registrar_Producto(p_Id_Categoria Producto.Id_Categoria%TYPE, p_Nombre Producto.Nombre%TYPE, p_Precio Producto.Precio%TYPE, p_id OUT Producto.Id_Producto%TYPE);
    PROCEDURE consultar_Producto(p_filas OUT SYS_REFCURSOR);
    PROCEDURE modificar_Producto(p_id Producto.Id_Producto%TYPE, p_Id_Categoria Producto.Id_Categoria%TYPE, p_Nombre Producto.Nombre%TYPE, p_Precio Producto.Precio%TYPE);
    PROCEDURE eliminar_Producto(p_id Producto.Id_Producto%TYPE);
    PROCEDURE registrar_Pedido(p_Id_Cliente Pedido.Id_Cliente%TYPE, p_Id_Empleado Pedido.Id_Empleado%TYPE, p_Id_Estado_Pedido Pedido.Id_Estado_Pedido%TYPE, p_Id_Tipo_Pedido Pedido.Id_Tipo_Pedido%TYPE, p_id OUT Pedido.Id_Pedido%TYPE);
    PROCEDURE consultar_Pedido(p_filas OUT SYS_REFCURSOR);
    PROCEDURE modificar_Pedido(p_id Pedido.Id_Pedido%TYPE, p_Id_Cliente Pedido.Id_Cliente%TYPE, p_Id_Empleado Pedido.Id_Empleado%TYPE, p_Id_Estado_Pedido Pedido.Id_Estado_Pedido%TYPE, p_Id_Tipo_Pedido Pedido.Id_Tipo_Pedido%TYPE);
    PROCEDURE eliminar_Pedido(p_id Pedido.Id_Pedido%TYPE);
    PROCEDURE registrar_Venta(p_Id_Cliente Venta.Id_Cliente%TYPE, p_Id_Empleado Venta.Id_Empleado%TYPE, p_Id_Metodo_Pago Venta.Id_Metodo_Pago%TYPE, p_Total Venta.Total%TYPE, p_id OUT Venta.Id_Venta%TYPE);
    PROCEDURE consultar_Venta(p_filas OUT SYS_REFCURSOR);
    PROCEDURE modificar_Venta(p_id Venta.Id_Venta%TYPE, p_Id_Cliente Venta.Id_Cliente%TYPE, p_Id_Empleado Venta.Id_Empleado%TYPE, p_Id_Metodo_Pago Venta.Id_Metodo_Pago%TYPE, p_Total Venta.Total%TYPE);
    PROCEDURE eliminar_Venta(p_id Venta.Id_Venta%TYPE);
    PROCEDURE registrar_Inventario(p_Id_Producto Inventario.Id_Producto%TYPE, p_Cantidad_Disponible Inventario.Cantidad_Disponible%TYPE, p_id OUT Inventario.Id_Inventario%TYPE);
    PROCEDURE consultar_Inventario(p_filas OUT SYS_REFCURSOR);
    PROCEDURE modificar_Inventario(p_id Inventario.Id_Inventario%TYPE, p_Id_Producto Inventario.Id_Producto%TYPE, p_Cantidad_Disponible Inventario.Cantidad_Disponible%TYPE);
    PROCEDURE eliminar_Inventario(p_id Inventario.Id_Inventario%TYPE);
    PROCEDURE roles(p_filas OUT SYS_REFCURSOR);
    PROCEDURE categorias(p_filas OUT SYS_REFCURSOR);
    PROCEDURE estados(p_filas OUT SYS_REFCURSOR);
    PROCEDURE tipos(p_filas OUT SYS_REFCURSOR);
    PROCEDURE metodos(p_filas OUT SYS_REFCURSOR);
    PROCEDURE resumen(p_filas OUT SYS_REFCURSOR);
END pkg_evy;
/

-- 6. CUERPO DEL PAQUETE
-- Implementa el CRUD, los catálogos y el resumen.
-- SYS_REFCURSOR permite devolver las filas de una consulta. PHP las lee a través de OCI8.
-- El código que llama a los procedimientos decide cuándo hacer COMMIT o ROLLBACK.
CREATE OR REPLACE PACKAGE BODY pkg_evy AS
    -- Valida los campos obligatorios y registra un cliente.
    -- NEXTVAL genera el ID. RETURNING INTO lo devuelve en p_id.
    PROCEDURE registrar_Cliente(p_Nombre Cliente.Nombre%TYPE, p_Telefono Cliente.Telefono%TYPE, p_Direccion Cliente.Direccion%TYPE, p_id OUT Cliente.Id_Clientes%TYPE) IS
    BEGIN
        IF TRIM(p_Nombre) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Nombre.');
        END IF;
        IF TRIM(p_Telefono) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Teléfono.');
        END IF;
        INSERT INTO Cliente (Id_Clientes, Nombre, Telefono, Direccion)
        VALUES (seq_Cliente.NEXTVAL, p_Nombre, p_Telefono, p_Direccion)
        RETURNING Id_Clientes INTO p_id;
    END;

    -- Abre el cursor de cliente con las filas de la vista, ordenadas por ID.
    PROCEDURE consultar_Cliente(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT * FROM vw_evy_Cliente ORDER BY Id_Clientes;
    END;

    -- Valida los datos y modifica un cliente por su ID.
    -- SQL%ROWCOUNT indica cuántas filas actualizó. Si es cero, el ID no existe.
    PROCEDURE modificar_Cliente(p_id Cliente.Id_Clientes%TYPE, p_Nombre Cliente.Nombre%TYPE, p_Telefono Cliente.Telefono%TYPE, p_Direccion Cliente.Direccion%TYPE) IS
    BEGIN
        IF TRIM(p_Nombre) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Nombre.');
        END IF;
        IF TRIM(p_Telefono) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Teléfono.');
        END IF;
        UPDATE Cliente
        SET Nombre = p_Nombre, Telefono = p_Telefono, Direccion = p_Direccion
        WHERE Id_Clientes = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Elimina un cliente por su ID. Si no encuentra la fila, devuelve un error.
    -- Oracle impide el borrado cuando otras filas dependen de ese registro.
    PROCEDURE eliminar_Cliente(p_id Cliente.Id_Clientes%TYPE) IS
    BEGIN
        DELETE FROM Cliente WHERE Id_Clientes = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Valida los campos obligatorios y registra un empleado.
    -- NEXTVAL genera el ID. RETURNING INTO lo devuelve en p_id.
    PROCEDURE registrar_Empleado(p_Id_Rol Empleado.Id_Rol%TYPE, p_Nombre Empleado.Nombre%TYPE, p_Telefono Empleado.Telefono%TYPE, p_id OUT Empleado.Id_Empleado%TYPE) IS
    BEGIN
        IF p_Id_Rol IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Rol.');
        END IF;
        IF TRIM(p_Nombre) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Nombre.');
        END IF;
        IF TRIM(p_Telefono) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Teléfono.');
        END IF;
        INSERT INTO Empleado (Id_Empleado, Id_Rol, Nombre, Telefono)
        VALUES (seq_Empleado.NEXTVAL, p_Id_Rol, p_Nombre, p_Telefono)
        RETURNING Id_Empleado INTO p_id;
    END;

    -- Abre el cursor de empleado con las filas de la vista, ordenadas por ID.
    PROCEDURE consultar_Empleado(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT * FROM vw_evy_Empleado ORDER BY Id_Empleado;
    END;

    -- Valida los datos y modifica un empleado por su ID.
    -- SQL%ROWCOUNT indica cuántas filas actualizó. Si es cero, el ID no existe.
    PROCEDURE modificar_Empleado(p_id Empleado.Id_Empleado%TYPE, p_Id_Rol Empleado.Id_Rol%TYPE, p_Nombre Empleado.Nombre%TYPE, p_Telefono Empleado.Telefono%TYPE) IS
    BEGIN
        IF p_Id_Rol IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Rol.');
        END IF;
        IF TRIM(p_Nombre) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Nombre.');
        END IF;
        IF TRIM(p_Telefono) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Teléfono.');
        END IF;
        UPDATE Empleado
        SET Id_Rol = p_Id_Rol, Nombre = p_Nombre, Telefono = p_Telefono
        WHERE Id_Empleado = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Elimina un empleado por su ID. Si no encuentra la fila, devuelve un error.
    -- Oracle impide el borrado cuando otras filas dependen de ese registro.
    PROCEDURE eliminar_Empleado(p_id Empleado.Id_Empleado%TYPE) IS
    BEGIN
        DELETE FROM Empleado WHERE Id_Empleado = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Valida los campos obligatorios y registra un producto.
    -- NEXTVAL genera el ID. RETURNING INTO lo devuelve en p_id.
    PROCEDURE registrar_Producto(p_Id_Categoria Producto.Id_Categoria%TYPE, p_Nombre Producto.Nombre%TYPE, p_Precio Producto.Precio%TYPE, p_id OUT Producto.Id_Producto%TYPE) IS
    BEGIN
        IF p_Id_Categoria IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Categoría.');
        END IF;
        IF TRIM(p_Nombre) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Nombre.');
        END IF;
        IF p_Precio IS NULL OR p_Precio < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Precio.');
        END IF;
        INSERT INTO Producto (Id_Producto, Id_Categoria, Nombre, Precio)
        VALUES (seq_Producto.NEXTVAL, p_Id_Categoria, p_Nombre, p_Precio)
        RETURNING Id_Producto INTO p_id;
    END;

    -- Abre el cursor de producto con las filas de la vista, ordenadas por ID.
    PROCEDURE consultar_Producto(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT * FROM vw_evy_Producto ORDER BY Id_Producto;
    END;

    -- Valida los datos y modifica un producto por su ID.
    -- SQL%ROWCOUNT indica cuántas filas actualizó. Si es cero, el ID no existe.
    PROCEDURE modificar_Producto(p_id Producto.Id_Producto%TYPE, p_Id_Categoria Producto.Id_Categoria%TYPE, p_Nombre Producto.Nombre%TYPE, p_Precio Producto.Precio%TYPE) IS
    BEGIN
        IF p_Id_Categoria IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Categoría.');
        END IF;
        IF TRIM(p_Nombre) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Nombre.');
        END IF;
        IF p_Precio IS NULL OR p_Precio < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Precio.');
        END IF;
        UPDATE Producto
        SET Id_Categoria = p_Id_Categoria, Nombre = p_Nombre, Precio = p_Precio
        WHERE Id_Producto = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Elimina un producto por su ID. Si no encuentra la fila, devuelve un error.
    -- Oracle impide el borrado cuando otras filas dependen de ese registro.
    PROCEDURE eliminar_Producto(p_id Producto.Id_Producto%TYPE) IS
    BEGIN
        DELETE FROM Producto WHERE Id_Producto = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Valida los campos obligatorios y registra un pedido.
    -- NEXTVAL genera el ID. RETURNING INTO lo devuelve en p_id.
    -- SYSDATE registra la fecha de creación.
    PROCEDURE registrar_Pedido(p_Id_Cliente Pedido.Id_Cliente%TYPE, p_Id_Empleado Pedido.Id_Empleado%TYPE, p_Id_Estado_Pedido Pedido.Id_Estado_Pedido%TYPE, p_Id_Tipo_Pedido Pedido.Id_Tipo_Pedido%TYPE, p_id OUT Pedido.Id_Pedido%TYPE) IS
    BEGIN
        IF p_Id_Cliente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Cliente.');
        END IF;
        IF p_Id_Empleado IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Empleado.');
        END IF;
        IF p_Id_Estado_Pedido IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Estado.');
        END IF;
        IF p_Id_Tipo_Pedido IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Tipo.');
        END IF;
        INSERT INTO Pedido (Id_Pedido, Id_Cliente, Id_Empleado, Id_Estado_Pedido, Id_Tipo_Pedido, Fecha_Pedido)
        VALUES (seq_Pedido.NEXTVAL, p_Id_Cliente, p_Id_Empleado, p_Id_Estado_Pedido, p_Id_Tipo_Pedido, SYSDATE)
        RETURNING Id_Pedido INTO p_id;
    END;

    -- Abre el cursor de pedido con las filas de la vista, ordenadas por ID.
    PROCEDURE consultar_Pedido(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT * FROM vw_evy_Pedido ORDER BY Id_Pedido;
    END;

    -- Valida los datos y modifica un pedido por su ID.
    -- SQL%ROWCOUNT indica cuántas filas actualizó. Si es cero, el ID no existe.
    PROCEDURE modificar_Pedido(p_id Pedido.Id_Pedido%TYPE, p_Id_Cliente Pedido.Id_Cliente%TYPE, p_Id_Empleado Pedido.Id_Empleado%TYPE, p_Id_Estado_Pedido Pedido.Id_Estado_Pedido%TYPE, p_Id_Tipo_Pedido Pedido.Id_Tipo_Pedido%TYPE) IS
    BEGIN
        IF p_Id_Cliente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Cliente.');
        END IF;
        IF p_Id_Empleado IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Empleado.');
        END IF;
        IF p_Id_Estado_Pedido IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Estado.');
        END IF;
        IF p_Id_Tipo_Pedido IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Tipo.');
        END IF;
        UPDATE Pedido
        SET Id_Cliente = p_Id_Cliente, Id_Empleado = p_Id_Empleado, Id_Estado_Pedido = p_Id_Estado_Pedido, Id_Tipo_Pedido = p_Id_Tipo_Pedido
        WHERE Id_Pedido = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Elimina un pedido por su ID. Si no encuentra la fila, devuelve un error.
    -- Oracle impide el borrado cuando otras filas dependen de ese registro.
    PROCEDURE eliminar_Pedido(p_id Pedido.Id_Pedido%TYPE) IS
    BEGIN
        DELETE FROM Pedido WHERE Id_Pedido = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Valida los campos obligatorios y registra una venta.
    -- NEXTVAL genera el ID. RETURNING INTO lo devuelve en p_id.
    -- SYSDATE registra la fecha de creación.
    PROCEDURE registrar_Venta(p_Id_Cliente Venta.Id_Cliente%TYPE, p_Id_Empleado Venta.Id_Empleado%TYPE, p_Id_Metodo_Pago Venta.Id_Metodo_Pago%TYPE, p_Total Venta.Total%TYPE, p_id OUT Venta.Id_Venta%TYPE) IS
    BEGIN
        IF p_Id_Cliente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Cliente.');
        END IF;
        IF p_Id_Empleado IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Empleado.');
        END IF;
        IF p_Id_Metodo_Pago IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Método de pago.');
        END IF;
        IF p_Total IS NULL OR p_Total < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Total.');
        END IF;
        INSERT INTO Venta (Id_Venta, Id_Cliente, Id_Empleado, Id_Metodo_Pago, Total, Fecha_Venta)
        VALUES (seq_Venta.NEXTVAL, p_Id_Cliente, p_Id_Empleado, p_Id_Metodo_Pago, p_Total, SYSDATE)
        RETURNING Id_Venta INTO p_id;
    END;

    -- Abre el cursor de venta con las filas de la vista, ordenadas por ID.
    PROCEDURE consultar_Venta(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT * FROM vw_evy_Venta ORDER BY Id_Venta;
    END;

    -- Valida los datos y modifica una venta por su ID.
    -- SQL%ROWCOUNT indica cuántas filas actualizó. Si es cero, el ID no existe.
    PROCEDURE modificar_Venta(p_id Venta.Id_Venta%TYPE, p_Id_Cliente Venta.Id_Cliente%TYPE, p_Id_Empleado Venta.Id_Empleado%TYPE, p_Id_Metodo_Pago Venta.Id_Metodo_Pago%TYPE, p_Total Venta.Total%TYPE) IS
    BEGIN
        IF p_Id_Cliente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Cliente.');
        END IF;
        IF p_Id_Empleado IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Empleado.');
        END IF;
        IF p_Id_Metodo_Pago IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Método de pago.');
        END IF;
        IF p_Total IS NULL OR p_Total < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Total.');
        END IF;
        UPDATE Venta
        SET Id_Cliente = p_Id_Cliente, Id_Empleado = p_Id_Empleado, Id_Metodo_Pago = p_Id_Metodo_Pago, Total = p_Total
        WHERE Id_Venta = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Elimina una venta por su ID. Si no encuentra la fila, devuelve un error.
    -- Oracle impide el borrado cuando otras filas dependen de ese registro.
    PROCEDURE eliminar_Venta(p_id Venta.Id_Venta%TYPE) IS
    BEGIN
        DELETE FROM Venta WHERE Id_Venta = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Valida los campos obligatorios y registra un registro de inventario.
    -- NEXTVAL genera el ID. RETURNING INTO lo devuelve en p_id.
    -- El trigger registra la fecha de actualización.
    PROCEDURE registrar_Inventario(p_Id_Producto Inventario.Id_Producto%TYPE, p_Cantidad_Disponible Inventario.Cantidad_Disponible%TYPE, p_id OUT Inventario.Id_Inventario%TYPE) IS
    BEGIN
        IF p_Id_Producto IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Producto.');
        END IF;
        IF p_Cantidad_Disponible IS NULL OR p_Cantidad_Disponible < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Cantidad.');
        END IF;
        INSERT INTO Inventario (Id_Inventario, Id_Producto, Cantidad_Disponible)
        VALUES (seq_Inventario.NEXTVAL, p_Id_Producto, p_Cantidad_Disponible)
        RETURNING Id_Inventario INTO p_id;
    END;

    -- Abre el cursor de inventario con las filas de la vista, ordenadas por ID.
    PROCEDURE consultar_Inventario(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT * FROM vw_evy_Inventario ORDER BY Id_Inventario;
    END;

    -- Valida los datos y modifica un registro de inventario por su ID.
    -- SQL%ROWCOUNT indica cuántas filas actualizó. Si es cero, el ID no existe.
    PROCEDURE modificar_Inventario(p_id Inventario.Id_Inventario%TYPE, p_Id_Producto Inventario.Id_Producto%TYPE, p_Cantidad_Disponible Inventario.Cantidad_Disponible%TYPE) IS
    BEGIN
        IF p_Id_Producto IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Producto.');
        END IF;
        IF p_Cantidad_Disponible IS NULL OR p_Cantidad_Disponible < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para Cantidad.');
        END IF;
        UPDATE Inventario
        SET Id_Producto = p_Id_Producto, Cantidad_Disponible = p_Cantidad_Disponible
        WHERE Id_Inventario = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Elimina un registro de inventario por su ID. Si no encuentra la fila, devuelve un error.
    -- Oracle impide el borrado cuando otras filas dependen de ese registro.
    PROCEDURE eliminar_Inventario(p_id Inventario.Id_Inventario%TYPE) IS
    BEGIN
        DELETE FROM Inventario WHERE Id_Inventario = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El registro no existe.');
        END IF;
    END;

    -- Lista los roles disponibles para el formulario de empleados.
    PROCEDURE roles(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT Id_Rol, Nombre_Rol FROM Rol ORDER BY 2;
    END;

    -- Lista las categorías que se pueden seleccionar al registrar productos.
    PROCEDURE categorias(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT Id_Categoria, Nombre_Categoria FROM Categoria ORDER BY 2;
    END;

    -- Lista los estados disponibles para un pedido.
    PROCEDURE estados(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT Id_Estado_Pedido, Descripcion FROM Estado_pedido ORDER BY 2;
    END;

    -- Lista los tipos de pedido.
    PROCEDURE tipos(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT Id_Tipo_Pedido, Nombre_Tipo FROM TipoPedido ORDER BY 2;
    END;

    -- Lista los medios de pago que se pueden seleccionar al registrar ventas.
    PROCEDURE metodos(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT Id_Metodo_Pago, Tipo_Pago FROM MetodoPago ORDER BY 2;
    END;

    -- Devuelve los conteos de clientes, productos, pedidos y ventas, más el monto acumulado.
    PROCEDURE resumen(p_filas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_filas FOR
            SELECT (SELECT COUNT(*) FROM Cliente) AS Clientes,
                   (SELECT COUNT(*) FROM Producto) AS Productos,
                   (SELECT COUNT(*) FROM Pedido) AS Pedidos,
                   (SELECT COUNT(*) FROM Venta) AS Ventas,
                   total_ventas() AS Monto_Ventas
            FROM dual;
    END;

END pkg_evy;
/

-- 7. REVISIÓN DE COMPILACIÓN
-- Muestra el objeto, la línea, la posición y el mensaje de los problemas registrados por Oracle.
SELECT name, type, line, position, text
FROM user_errors
WHERE name IN ('PKG_EVY', 'SUBTOTAL_VENTA', 'TOTAL_VENTAS',
               'TRG_PRECIO_PRODUCTO', 'TRG_ACTUALIZA_INVENTARIO')
ORDER BY name, type, sequence;

-- Cuenta solo errores de compilación y detiene el script si encuentra alguno.
DECLARE
    v_errores NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_errores FROM user_errors
    WHERE name IN ('PKG_EVY', 'SUBTOTAL_VENTA', 'TOTAL_VENTAS',
                   'TRG_PRECIO_PRODUCTO', 'TRG_ACTUALIZA_INVENTARIO')
      AND attribute = 'ERROR';
    IF v_errores > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Revisar errores de compilación.');
    END IF;
END;
/
--NUEVO APORTE

create or replace function contar_clientes
return number
is 
v_total number;
begin
select count(*) into v_total
from cliente;
return v_total;
end;
/

create or replace function contar_productos
return number
is
v_total_p number;
begin
select count(*) into v_total_p from producto;
return v_total_p;
end;
/

create or replace function contar_pedidos
return number
is 
v_total_pedido number;
begin
select count(*) into v_total_pedido from pedido;
return v_total_pedido;
end;
/

create or replace function obtener_precio_producto(producto_id number)
return number
is
v_precio number(10,2);
begin
select precio into v_precio from producto
where id_producto = producto_id;
return v_precio;
exception
when no_data_found then
return null;
end;
/

create or replace function calcular_total_inventario
return number
is
v_total_inventario number (12,2);
begin
select sum(i.cantidad_disponible * p.precio)
into v_total_inventario
from inventario i
join producto p
on i.id_producto = p.id_producto;
return v_total_inventario;
end;
/

create or replace function clasificacion_inventario(producto_id number)
return varchar2
is
v_cantidad number;
v_clasificacion_inventario varchar2(50);
begin
select cantidad_disponible into v_cantidad from inventario
where id_producto = producto_id;

if v_cantidad < 10 then v_clasificacion_inventario := 'bajo';

elsif v_cantidad <= 30 then v_clasificacion_inventario := 'medio';

else
v_clasificacion_inventario := 'alto';
end if;

return v_clasificacion_inventario;

exception
when no_data_found then return 'sin inventario';
end;
/

-- TRIGGER

create or replace trigger trg_cantidad_movimiento
before insert or update on movimientoinventario
for each row
begin
if :new.cantidad is null or :new.cantidad <=0 then
raise_application_error(-20005, 'la cantidad debe ser mayor a cero');
end if;
end;
/

--PAQUETES

create or replace package pkg_clientes
is
procedure buscar_cliente(cliente_id number,resultado out sys_refcursor);
end pkg_clientes;
/

create or replace package body pkg_clientes
is
procedure buscar_cliente( cliente_id number, resultado out sys_refcursor)
is
begin 
open resultado for
select id_clientes, nombre, telefono, direccion from cliente
where id_clientes = cliente_id;
end;
end pkg_clientes;
/
----------------------------
create or replace package pkg_productos 
is
procedure buscar_producto(producto_id number, resultado out sys_refcursor);
end pkg_productos;
/

create or replace package body pkg_productos
is
procedure buscar_producto(producto_id number, resultado out sys_refcursor)
is 
begin
open resultado for 
select id_producto, nombre, precio
from producto
where id_producto = producto_id;
end;
end pkg_productos;
/

------------------------------
create or replace package pkg_pedidos
is
procedure buscar_pedido(pedido_id number, resultado out sys_refcursor);
end pkg_pedidos;
/

 create or replace package body pkg_pedidos
 is
 procedure buscar_pedido(pedido_id number, resultado out sys_refcursor)
 is 
 begin
 open resultado for
 select * from pedido where id_pedido = pedido_id;
 end;
 end pkg_pedidos;
 /

--------------------------
create or replace package pkg_inventarios
is
procedure buscar_inventarios(producto_id number, resultado out sys_refcursor);
end pkg_inventarios;
/

create or replace package body pkg_inventarios
is
procedure buscar_inventarios(producto_id number, resultado out sys_refcursor)
is
begin
open resultado for
select i.id_inventario, p.nombre, i.cantidad_disponible, i.fecha_actualizacion
from inventario i
join producto p
on i.id_producto = p.id_producto
where i.id_producto = producto_id;
end;
end pkg_inventarios;
/

