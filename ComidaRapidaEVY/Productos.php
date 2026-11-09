<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Productos - Comida Rápida EVY</title>

    <link rel="stylesheet" href="Estilos.css?v=3">
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
        <div class= "contenido">

            <h1>productos</h1>
            <p>Administración de productos del restaurante.</p>

            <div class="opciones">
                <input type="text" id="buscarproducto" placeholder="Buscar producto">
                <button type="button" id="nuevoproducto">Nuevo producto</button>
            </div>
            
            <div class="formulario" id="formularioproducto">

                <h2>Registrar nuevo producto</h2>

                <form id="registroproducto">

                    <label for="categoria">Categoría</label>
                    <select id="categoria" name="categoria" required>
                        <option value="">Seleccione una categoría</option>
                        <option value="Comidas">Comidas</option>
                        <option value="Bebidas">Bebidas</option>
                        <option value="Postres">Postres</option>
                    </select>

                    <label for="nombreproducto">Nombre del producto</label>
                    <input type="text" id="nombreproducto" required>

                    <label for="precioproducto">Precio</label>
                    <input type="number" id="precioproducto" min="0" step="0.01" required>

                    <button type="submit">Guardar producto</button>
                    <button type="button" id="cancelarproducto">Cancelar</button>

                </form>

            </div> 
            <table>
                <thead>
                    <tr>
                        <th>id</th>
                        <th>categoría</th>
                        <th>nombre</th>
                        <th>precio</th>
                        <th>acciones</th>
                    </tr>
                </thead>
                <tbody id="tablaproductos">
                    <tr>
                        <td>1</td>
                        <td>Hamburguesas</td>
                        <td>Hamburguesa</td>
                        <td>₡2500</td>
                        <td>
                            <button type="button" class="modificarproducto">Modificar</button>
                            <button type="button" class="eliminarproducto">Eliminar</button>
                        </td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td>Acompañamientos</td>
                        <td>Papas fritas</td>
                        <td>₡1500</td>
                        <td>
                            <button type="button" class="modificarproducto">Modificar</button>
                            <button type="button" class="eliminarproducto">Eliminar</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <script>

        const botonnuevo = document.getElementById("nuevoproducto");
        const formulario = document.getElementById("formularioproducto");
        const botoncancelar = document.getElementById("cancelarproducto");
        const campoCategoria = document.getElementById("categoria");
        const campoNombre = document.getElementById("nombreproducto");
        const campoPrecio = document.getElementById("precioproducto");
        const tablaProductos = document.getElementById("tablaproductos");
        const buscarProducto = document.getElementById("buscarproducto");
        let filaSeleccionada = null;
        let siguienteId = 3;
        botonnuevo.addEventListener("click", function() {
            filaSeleccionada = null;
            document.getElementById("registroproducto").reset();
            formulario.style.display = "block";
        });

        botoncancelar.addEventListener("click", function() {
            formulario.style.display = "none";
            filaSeleccionada = null;
        });

        
        tablaProductos.addEventListener("click", function(evento) {

            if (evento.target.classList.contains("modificarproducto")) {

                const fila = evento.target.closest("tr");

                filaSeleccionada = fila;

                const categoria = fila.cells[1].textContent;
                const nombre = fila.cells[2].textContent;
                const precio = fila.cells[3].textContent;

                campoCategoria.value = categoria;
                campoNombre.value = nombre;
                campoPrecio.value = precio.replace("₡", "").trim();

                formulario.style.display = "block";

            }
            
            if (evento.target.classList.contains("eliminarproducto")) {

                const fila = evento.target.closest("tr");

                const nombre = fila.cells[2].textContent;

                const confirmar = confirm("¿Estás seguro de eliminar el producto " + nombre + "?");

                if (confirmar) {

                    if (filaSeleccionada === fila) {
                        filaSeleccionada = null;
                        formulario.style.display = "none";
                    }

                    fila.remove();

                    alert("Producto eliminado correctamente.");

                }

            }

        });

        buscarProducto.addEventListener("input", function() {

            const busqueda = buscarProducto.value.toLowerCase();

            const filas = tablaProductos.querySelectorAll("tr");

            filas.forEach(function(fila) {

                const id = fila.cells[0].textContent.toLowerCase();
                const categoria = fila.cells[1].textContent.toLowerCase();
                const nombre = fila.cells[2].textContent.toLowerCase();

                if (id.includes(busqueda) || categoria.includes(busqueda) || nombre.includes(busqueda)) {

                    fila.style.display = "";
                } else {
                    fila.style.display = "none";

                }
            });
        });
        

        document.getElementById("registroproducto").addEventListener("submit", function(evento) {

                evento.preventDefault();

                const categoria = campoCategoria.value;
                const nombre = campoNombre.value;
                const precio = campoPrecio.value;

                if (filaSeleccionada === null) {

                    
                    const fila = tablaProductos.insertRow();

                    fila.insertCell(0).textContent = siguienteId;
                    siguienteId++;
                    fila.insertCell(1).textContent = categoria;
                    fila.insertCell(2).textContent = nombre;
                    fila.insertCell(3).textContent = "₡" + precio;

                    const acciones = fila.insertCell(4);

                    acciones.innerHTML = `<button type="button" class="modificarproducto">Modificar</button>
                        <button type="button" class="eliminarproducto">Eliminar</button>`;

                    alert("Producto registrado correctamente.");

                } else {
                    
                    filaSeleccionada.cells[1].textContent = categoria;
                    filaSeleccionada.cells[2].textContent = nombre;
                    filaSeleccionada.cells[3].textContent = "₡" + precio;
                    alert("Producto modificado correctamente.");
                }
                formulario.style.display = "none";
                filaSeleccionada = null;

            });
    </script>

</body>
</html>
            