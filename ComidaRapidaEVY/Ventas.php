
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ventas - Comida Rápida EVY</title>
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

            <h1>Ventas</h1>
            <p>Consulta de ventas realizadas en el restaurante.</p>

            <div class="opciones">
                <input type="text" id="buscarventa"placeholder="Buscar venta">

                <button type="button" id="nuevaventa">Nueva venta</button>
            </div>
            <div class="formulario" id="formularioventa">

                <h2>Registrar nueva venta</h2>

                <form id="registroventa">

                    <label for="pedidoventa">Pedido</label>
                    <select id="pedidoventa" required>

                        <option value="">Seleccione un pedido</option>
                        <option value="Pedido 1">Pedido 1</option>
                        <option value="Pedido 2">Pedido 2</option>

                    </select>

                    <label for="totalventa">Total de la venta</label>
                    <input type="number" id="totalventa" min="1" placeholder="Ingrese el total" required>

                    <button type="submit">Guardar venta</button>
                    <button type="button" id="cancelarventa">Cancelar</button>

                </form>

            </div>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Pedido</th>
                        <th>Fecha</th>
                        <th>Total</th>
                        <th>Acciones</th>
                    </tr>
                </thead>

                <tbody id="tablaventas">

                    <tr>
                        <td>1</td>
                        <td>Pedido 1</td>
                        <td>07/11/2026</td>
                        <td>₡4500</td>
                        <td>
                            <button type="button" class="modificarventa">Modificar</button>
                            <button type="button" class="eliminarventa">Eliminar</button>
                        </td>
                    </tr>

                    <tr>
                        <td>2</td>
                        <td>Pedido 2</td>
                        <td>07/11/2026</td>
                        <td>₡6500</td>
                        <td>
                            <button type="button" class="modificarventa">Modificar</button>
                            <button type="button" class="eliminarventa">Eliminar</button>
                        </td>
                    </tr>

                </tbody>
            </table>

        </div>
    </div>

    <script>

        const botonnuevo = document.getElementById("nuevaventa");
        const formulario = document.getElementById("formularioventa");
        const botoncancelar = document.getElementById("cancelarventa");

        const campoPedido = document.getElementById("pedidoventa");
        const campoTotal = document.getElementById("totalventa");

        let filaSeleccionada = null;
        let siguienteId = 3;

        botonnuevo.addEventListener("click", function() {

            filaSeleccionada = null;
            document.getElementById("registroventa").reset();
            formulario.style.display = "block";

        });

        botoncancelar.addEventListener("click", function() {

            formulario.style.display = "none";
            filaSeleccionada = null;

        });
        
        document.getElementById("registroventa").addEventListener("submit", function(evento) {

            evento.preventDefault();

            const pedido = campoPedido.value;
            const total = campoTotal.value;
            const fecha = new Date().toLocaleDateString("es-CR");
            const tabla = document.getElementById("tablaventas");
            if (filaSeleccionada !== null) {
                filaSeleccionada.cells[1].textContent = pedido;
                filaSeleccionada.cells[3].textContent = "₡" + Number(total).toLocaleString("es-CR");

                alert("Venta modificada correctamente.");

                formulario.style.display = "none";
                filaSeleccionada = null;

                return;

            }

            const fila = tabla.insertRow();

            fila.insertCell(0).textContent = siguienteId;
            fila.insertCell(1).textContent = pedido;
            fila.insertCell(2).textContent = fecha;
            fila.insertCell(3).textContent = "₡" + Number(total).toLocaleString("es-CR");

            const acciones = fila.insertCell(4);

            acciones.innerHTML = `<button type="button" class="modificarventa">Modificar</button><button type="button" class="eliminarventa">Eliminar</button>`;
            siguienteId++;

            alert("Venta registrada correctamente.");
            formulario.style.display = "none";
            document.getElementById("registroventa").reset();

        });
        
        document.getElementById("tablaventas").addEventListener("click", function(evento) {

            if (evento.target.classList.contains("modificarventa")) {

                const fila = evento.target.closest("tr");
                filaSeleccionada = fila;
                const pedido = fila.cells[1].textContent;
                const total = fila.cells[3].textContent.replace(/[^\d]/g, "");

                campoPedido.value = pedido;
                campoTotal.value = total;

                formulario.style.display = "block";

            }

            if (evento.target.classList.contains("eliminarventa")) {

                const fila = evento.target.closest("tr");

                const confirmar = confirm("¿Desea eliminar esta venta?");

                if (confirmar) {

                    if (filaSeleccionada === fila) {
                        filaSeleccionada = null;
                        formulario.style.display = "none";
                    }

                    fila.remove();
                    alert("Venta eliminada correctamente.");
                }

            }


        });

        document.getElementById("buscarventa").addEventListener("input", function() {

            const busqueda = this.value.toLowerCase();
            const filas = document.querySelectorAll("#tablaventas tr");

            filas.forEach(function(fila) {

                const id = fila.cells[0].textContent.toLowerCase();
                const pedido = fila.cells[1].textContent.toLowerCase();

                if (id.includes(busqueda) || pedido.includes(busqueda)) {
                    fila.style.display = "";
                } else {
                    fila.style.display = "none";
                }

            });

        });

    </script>

</body>
</html>
