
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventarios - Comida Rápida EVY</title>
    <link rel="stylesheet" href="Estilos.css">
</head>

<body>

    <div class="contenedor">

        <div class="menu">
            <h2>Comida Rápida EVY</h2>

            <a href="index.php">Inicio</a>
            <a href="Clientes.php">Clientes</a>
            <a href="Productos.php">Productos</a>
            <a href="Empleados.php">Empleados</a>
            <a href="Pedidos.php">Pedidos</a>
            <a href="Ventas.php">Ventas</a>
            <a href="Inventarios.php">Inventarios</a>
        </div>

        <div class="contenido">

            <h1>Inventarios</h1>
            <p>Control de existencias del restaurante.</p>

            <div class="opciones">
                <input type="text" id="buscarinventario" placeholder="Buscar producto">
                <button type="button" id="nuevoinventario">Nuevo registro</button>
            </div>
            <div class="formulario" id="formularioinventario">

                <h2>Registrar nuevo inventario</h2>

                <form id="registroinventario">

                    <label for="productoinventario">Producto</label>
                    <input type="text" id="productoinventario" placeholder="Ingrese el producto" required>

                    <label for="cantidadinventario">Cantidad</label>
                    <input type="number" id="cantidadinventario" min="0" placeholder="Ingrese la cantidad" required>

                    <label for="unidadinventario">Unidad</label>
                    <select id="unidadinventario" required>

                        <option value="">Seleccione una unidad</option>
                        <option value="Unidades">Unidades</option>
                        <option value="Kilogramos">Kilogramos</option>
                        <option value="Gramos">Gramos</option>
                        <option value="Litros">Litros</option>

                    </select>

                    <button type="submit">Guardar inventario</button>
                    <button type="button" id="cancelarinventario">Cancelar</button>

                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Producto</th>
                        <th>Cantidad</th>
                        <th>Unidad</th>
                        <th>Acciones</th>
                    </tr>
                </thead>

                <tbody id="tablainventarios">

                    <tr>
                        <td>1</td>
                        <td>Pan para hamburguesa</td>
                        <td>50</td>
                        <td>Unidades</td>
                        <td>
                            <button type="button" class="modificarinventario">Modificar</button>
                            <button type="button" class="eliminarinventario">Eliminar</button>
                        </td>
                    </tr>

                    <tr>
                        <td>2</td>
                        <td>Papas congeladas</td>
                        <td>20</td>
                        <td>Kilogramos</td>
                        <td>
                            <button type="button" class="modificarinventario">Modificar</button>
                            <button type="button" class="eliminarinventario">Eliminar</button>
                        </td>
                    </tr>

                </tbody>
            </table>

        </div>
    </div>
    <script>

        const botonnuevo = document.getElementById("nuevoinventario");
        const formulario = document.getElementById("formularioinventario");
        const botoncancelar = document.getElementById("cancelarinventario");

        const campoProducto = document.getElementById("productoinventario");
        const campoCantidad = document.getElementById("cantidadinventario");
        const campoUnidad = document.getElementById("unidadinventario");

        let filaSeleccionada = null;
        let siguienteId = 3;

        botonnuevo.addEventListener("click", function() {

            filaSeleccionada = null;
            document.getElementById("registroinventario").reset();
            formulario.style.display = "block";

        });

        botoncancelar.addEventListener("click", function() {

            formulario.style.display = "none";
            filaSeleccionada = null;

        });
        
        document.getElementById("registroinventario").addEventListener("submit", function(evento) {
            evento.preventDefault();
            const producto = campoProducto.value.trim();
            const cantidad = campoCantidad.value;
            const unidad = campoUnidad.value;
            const tabla = document.getElementById("tablainventarios");

            if (filaSeleccionada !== null) {

                filaSeleccionada.cells[1].textContent = producto;
                filaSeleccionada.cells[2].textContent = cantidad;
                filaSeleccionada.cells[3].textContent = unidad;

                alert("Inventario modificado correctamente.");

                formulario.style.display = "none";
                filaSeleccionada = null;

                return;

            }

            const fila = tabla.insertRow();

            fila.insertCell(0).textContent = siguienteId;
            fila.insertCell(1).textContent = producto;
            fila.insertCell(2).textContent = cantidad;
            fila.insertCell(3).textContent = unidad;

            const acciones = fila.insertCell(4);

            acciones.innerHTML = `<button type="button" class="modificarinventario">Modificar</button>
                <button type="button" class="eliminarinventario">Eliminar</button>`;

            siguienteId++;

            alert("Inventario registrado correctamente.");

            formulario.style.display = "none";

            document.getElementById("registroinventario").reset();

        });

        document.getElementById("tablainventarios").addEventListener("click", function(evento) {

            if (evento.target.classList.contains("modificarinventario")) {

                const fila = evento.target.closest("tr");
                filaSeleccionada = fila;
                const producto = fila.cells[1].textContent;
                const cantidad = fila.cells[2].textContent;
                const unidad = fila.cells[3].textContent;

                campoProducto.value = producto;
                campoCantidad.value = cantidad;
                campoUnidad.value = unidad;

                formulario.style.display = "block";

            }
            if (evento.target.classList.contains("eliminarinventario")) {

                const fila = evento.target.closest("tr");
                const producto = fila.cells[1].textContent;

                const confirmar = confirm("¿Desea eliminar el producto " + producto + "?");

                if (confirmar) {
                    if (filaSeleccionada === fila) {
                        filaSeleccionada = null;
                        formulario.style.display = "none";
                    }

                    fila.remove();
                    alert("Inventario eliminado correctamente.");
                }

            }
        });

        document.getElementById("buscarinventario").addEventListener("input", function() {
            const busqueda = this.value.toLowerCase();
            const filas = document.querySelectorAll("#tablainventarios tr");

            filas.forEach(function(fila) {
                const id = fila.cells[0].textContent.toLowerCase();
                const producto = fila.cells[1].textContent.toLowerCase();

                if (id.includes(busqueda) || producto.includes(busqueda)) {
                    fila.style.display = "";
                } else {
                    fila.style.display = "none";
                }
            });
        });

    </script>

</body>
</html>
