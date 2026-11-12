SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK


DECLARE
    v_cliente Cliente.Id_Clientes%TYPE;
    v_empleado Empleado.Id_Empleado%TYPE;
    v_producto Producto.Id_Producto%TYPE;
    v_pedido Pedido.Id_Pedido%TYPE;
    v_venta Venta.Id_Venta%TYPE;
    v_inventario Inventario.Id_Inventario%TYPE;
    v_fecha Inventario.Fecha_Actualizacion%TYPE;
    v_cursor SYS_REFCURSOR;
    v_total_antes NUMBER;
    v_cantidad NUMBER;
    v_filas NUMBER;

    PROCEDURE verificar(p_condicion BOOLEAN, p_prueba VARCHAR2) IS
    BEGIN
        IF p_condicion THEN
            DBMS_OUTPUT.PUT_LINE('OK - ' || p_prueba);
        ELSE
            RAISE_APPLICATION_ERROR(-20100, 'Falló: ' || p_prueba);
        END IF;
    END;
BEGIN
    SAVEPOINT inicio_evy;
    v_total_antes := total_ventas();

    pkg_evy.registrar_cliente('Cliente prueba', '88880010', 'Heredia', v_cliente);
    pkg_evy.registrar_empleado(1, 'Empleado prueba', '88880020', v_empleado);
    pkg_evy.registrar_producto(1, 'Producto prueba', 1500, v_producto);
    pkg_evy.registrar_pedido(v_cliente, v_empleado, 1, 1, v_pedido);
    pkg_evy.registrar_venta(v_cliente, v_empleado, 1, 1500, v_venta);
    pkg_evy.registrar_inventario(v_producto, 10, v_inventario);
    verificar(total_ventas() = v_total_antes + 1500, 'Registro de venta y función total_ventas');
    verificar(subtotal_venta(v_venta) = 0, 'Función subtotal_venta para una venta sin detalles');

    pkg_evy.modificar_cliente(v_cliente, 'Cliente editado', '88880010', 'Cartago');
    pkg_evy.modificar_empleado(v_empleado, 2, 'Empleado editado', '88880020');
    pkg_evy.modificar_producto(v_producto, 2, 'Producto editado', 1750);
    pkg_evy.modificar_pedido(v_pedido, v_cliente, v_empleado, 2, 2);
    pkg_evy.modificar_venta(v_venta, v_cliente, v_empleado, 2, 1750);
    pkg_evy.modificar_inventario(v_inventario, v_producto, 12);

    SELECT COUNT(*) INTO v_filas FROM vw_evy_cliente
    WHERE Id_Clientes = v_cliente AND Direccion = 'Cartago';
    verificar(v_filas = 1, 'Vista de clientes muestra el cambio');

    SELECT COUNT(*) INTO v_filas FROM vw_evy_empleado
    WHERE Id_Empleado = v_empleado AND Id_Rol = 2;
    verificar(v_filas = 1, 'Vista de empleados muestra el cambio');

    SELECT COUNT(*) INTO v_filas FROM vw_evy_producto
    WHERE Id_Producto = v_producto AND Precio = 1750;
    verificar(v_filas = 1, 'Vista de productos muestra el cambio');

    SELECT COUNT(*) INTO v_filas FROM vw_evy_pedido
    WHERE Id_Pedido = v_pedido AND Id_Estado_Pedido = 2 AND Id_Tipo_Pedido = 2;
    verificar(v_filas = 1, 'Vista de pedidos muestra el cambio');

    SELECT COUNT(*) INTO v_filas FROM vw_evy_venta
    WHERE Id_Venta = v_venta AND Total = 1750 AND Id_Metodo_Pago = 2;
    verificar(v_filas = 1, 'Vista de ventas muestra el cambio');

    SELECT Cantidad_Disponible, Fecha_Actualizacion INTO v_cantidad, v_fecha
    FROM Inventario WHERE Id_Inventario = v_inventario;
    verificar(v_cantidad = 12 AND v_fecha IS NOT NULL, 'Edición de inventario y trigger de fecha');

    -- Cursor explícito para recorrer las filas que devuelve el procedimiento.
    DECLARE
        v_id Cliente.Id_Clientes%TYPE;
        v_nombre Cliente.Nombre%TYPE;
        v_tel Cliente.Telefono%TYPE;
        v_dir Cliente.Direccion%TYPE;
        v_encontrado BOOLEAN := FALSE;
    BEGIN
        pkg_evy.consultar_cliente(v_cursor);
        LOOP
            FETCH v_cursor INTO v_id, v_nombre, v_tel, v_dir;
            EXIT WHEN v_cursor%NOTFOUND;
            IF v_id = v_cliente AND v_nombre = 'Cliente editado' THEN
                v_encontrado := TRUE;
            END IF;
        END LOOP;
        CLOSE v_cursor;
        verificar(v_encontrado, 'Cursor SYS_REFCURSOR devuelve el cliente editado');
    END;

    BEGIN
        UPDATE Producto SET Precio = -1 WHERE Id_Producto = v_producto;
        verificar(FALSE, 'Trigger debe rechazar precio negativo');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE <> -20001 THEN RAISE; END IF;
            DBMS_OUTPUT.PUT_LINE('OK - Trigger rechaza un precio negativo');
    END;

    BEGIN
        UPDATE Inventario SET Cantidad_Disponible = -1 WHERE Id_Inventario = v_inventario;
        verificar(FALSE, 'Trigger debe rechazar cantidad negativa');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE <> -20002 THEN RAISE; END IF;
            DBMS_OUTPUT.PUT_LINE('OK - Trigger rechaza una cantidad negativa');
    END;

    BEGIN
        pkg_evy.eliminar_cliente(v_cliente);
        verificar(FALSE, 'La clave foránea debe impedir eliminar un cliente con ventas');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE <> -2292 THEN RAISE; END IF;
            DBMS_OUTPUT.PUT_LINE('OK - Oracle protege los registros relacionados');
    END;

    pkg_evy.eliminar_inventario(v_inventario);
    pkg_evy.eliminar_venta(v_venta);
    pkg_evy.eliminar_pedido(v_pedido);
    pkg_evy.eliminar_producto(v_producto);
    pkg_evy.eliminar_empleado(v_empleado);
    pkg_evy.eliminar_cliente(v_cliente);

    SELECT
        (SELECT COUNT(*) FROM Cliente WHERE Id_Clientes = v_cliente)
      + (SELECT COUNT(*) FROM Empleado WHERE Id_Empleado = v_empleado)
      + (SELECT COUNT(*) FROM Producto WHERE Id_Producto = v_producto)
      + (SELECT COUNT(*) FROM Pedido WHERE Id_Pedido = v_pedido)
      + (SELECT COUNT(*) FROM Venta WHERE Id_Venta = v_venta)
      + (SELECT COUNT(*) FROM Inventario WHERE Id_Inventario = v_inventario)
    INTO v_filas FROM dual;
    verificar(v_filas = 0, 'Eliminación confirmada en los seis módulos');

    ROLLBACK TO inicio_evy;
    DBMS_OUTPUT.PUT_LINE('PRUEBAS COMPLETADAS. Datos de prueba revertidos.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_evy;
        RAISE;
END;
/
