<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>clientes - Comida Rápida EVY</title>

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

            <h1>clientes</h1>
            <p>Administración de clientes del restaurante.</p>

            <div class="opciones">
                <input type="text" id="buscarcliente" placeholder="Buscar cliente">
                <button type="button" id="nuevocliente">Nuevo cliente</button>

            </div>

            <div class="formulario" id="formulariocliente">

                <h2>Registrar nuevo cliente</h2>
                <form id="registrocliente">

                    <label for="nombre"> nombre completo</label>
                    <input type="text" id="nombre" name="nombre" required>
                    <label for="telefono">telefono</label>
                    <input type="tel" id="telefono" name="telefono" required>
                    <label for="direccion">direccion</label>
                    <input type="text" id="direccion" name="direccion">
                    <button type="submit">guardar clientes</button>
                    <button type="button" id="cancelarcliente">cancelar</button>
                </form>

            </div>
            <table>

                <thead>
                    <tr>
                        <th>id</th>
                        <th>nombre</th>
                        <th>telefono</th>
                        <th>direccion</th>
                        <th>Acciones</th>
                    </tr>
                </thead>

                <tbody id="tablaclientes">
                    <tr>
                        <td>1</td>
                        <td>Gahel Ulate</td>
                        <td>6578-1235</td>
                        <td>Dirección de prueba</td>
                        <td>
                            <button type="button" class="modificarcliente">Modificar</button>
                            <button type="button" class="eliminarcliente">Eliminar</button>
                        </td>
                    </tr>

                    <tr>
                        <td>2</td>
                        <td>Luis Carlos</td>
                        <td>8564-5214</td>
                        <td>Dirección de prueba</td>
                        <td>
                            <button type="button" class="modificarcliente">Modificar</button>
                            <button type="button" class="eliminarcliente">Eliminar</button>
                        </td>
                    </tr>
                </tbody>
            </table>

        </div>
    </div>

    <script>

        const botonnuevo = document.getElementById('nuevocliente');
        const formulario = document.getElementById('formulariocliente');
        const botoncancelar = document.getElementById('cancelarcliente');
        const campoNombre = document.getElementById('nombre');
        const campoTelefono = document.getElementById('telefono');
        const campoDireccion = document.getElementById('direccion');
        const tablaClientes = document.getElementById('tablaclientes');
        const buscarCliente = document.getElementById('buscarcliente');
        let filaSeleccionada = null;
        let siguienteId = 3;


        botonnuevo.addEventListener("click", function() {
            filaSeleccionada = null;

            campoNombre.value = "";
            campoTelefono.value = "";
            campoDireccion.value = "";
        
            formulario.style.display = "block";
        });

        botoncancelar.addEventListener("click", function() {
            formulario.style.display = "none";
            filaSeleccionada = null;
        });

        tablaClientes.addEventListener("click", function(evento) {

            if (evento.target.classList.contains("modificarcliente")) {

                const fila = evento.target.closest("tr");

                filaSeleccionada = fila;

                const nombre = fila.cells[1].textContent;
                const telefono = fila.cells[2].textContent;
                const direccion = fila.cells[3].textContent;

                campoNombre.value = nombre;
                campoTelefono.value = telefono;
                campoDireccion.value = direccion;

                formulario.style.display = "block";

            }
            if (evento.target.classList.contains("eliminarcliente")) {
                const fila = evento.target.closest("tr");
                const nombre = fila.cells[1].textContent;
                const confirmar = confirm("¿Estás seguro de eliminar al cliente " + nombre + "?");

                if (confirmar) {

                    if (filaSeleccionada === fila) {
                        filaSeleccionada = null;
                        formulario.style.display = "none";
                    }
                    fila.remove();
                    alert("Cliente eliminado correctamente.");
                }
            }


        });



        document.getElementById("registrocliente").addEventListener("submit", function(evento) {
            evento.preventDefault();

            const nombre = campoNombre.value;
            const telefono = campoTelefono.value;
            const direccion = campoDireccion.value;

            if (filaSeleccionada == null) {
                const fila = tablaClientes.insertRow();
                fila.insertCell(0).textContent = siguienteId;
                siguienteId++;
                fila.insertCell(1).textContent = nombre;
                fila.insertCell(2).textContent = telefono;
                fila.insertCell(3).textContent = direccion;

                const acciones = fila.insertCell(4);

                acciones.innerHTML = `<button type="button" class="modificarcliente">Modificar</button>
                    <button type="button" class="eliminarcliente">Eliminar</button>`;

                alert("Cliente registrado correctamente.");

            } else {
                filaSeleccionada.cells[1].textContent = nombre;
                filaSeleccionada.cells[2].textContent = telefono;
                filaSeleccionada.cells[3].textContent = direccion;

                alert("Cliente modificado correctamente.");

            }
            formulario.style.display = "none";
            filaSeleccionada = null;
        });

        buscarCliente.addEventListener("input", function() {
            const busqueda = buscarCliente.value.toLowerCase();
            const filas = tablaClientes.querySelectorAll("tr");

            filas.forEach(function(fila) {
                const id = fila.cells[0].textContent.toLowerCase();
                const nombre = fila.cells[1].textContent.toLowerCase();
                const telefono = fila.cells[2].textContent.toLowerCase();

                if (id.includes(busqueda) || nombre.includes(busqueda) || telefono.includes(busqueda)) {
                    fila.style.display = "";
                } else {
                    fila.style.display = "none";
                }
            });
        });
    </script>

</body>
</html>