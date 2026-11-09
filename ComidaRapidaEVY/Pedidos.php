
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pedidos - Comida Rápida EVY</title>
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

            <h1>Pedidos</h1>
            <p>Administración de pedidos del restaurante.</p>

            <div class="opciones">
                <input type="text" id="buscarpedido"placeholder="Buscar pedido">
                <button type="button" id="nuevopedido">Nuevo pedido</button>
            </div> 
        
        <div class="formulario" id="formulariopedido">

            <h2>Registrar nuevo pedido</h2>

            <form id="registropedido">

                <label for="clientepedido">Cliente</label>
                <select id="clientepedido" required>

                    <option value="">Seleccione un cliente</option>
                    <option value="Gahel Ulate">Gahel Ulate</option>
                    <option value="Luis Carlos">Luis Carlos</option>

                </select>

                <label for="empleadopedido">Empleado</label>
                <select id="empleadopedido" required>

                    <option value="">Seleccione un empleado</option>
                    <option value="Carlos Rodríguez">Carlos Rodríguez</option>
                    <option value="María Fernández">María Fernández</option>

                </select>

                <label for="tipopedido">Tipo de pedido</label>
                <select id="tipopedido" required>

                    <option value="">Seleccione un tipo</option>
                    <option value="Local">Local</option>
                    <option value="Express">Express</option>
                    <option value="Para llevar">Para llevar</option>

                </select>

                <label for="estadopedido">Estado</label>
                <select id="estadopedido" required>

                    <option value="">Seleccione un estado</option>
                    <option value="Pendiente">Pendiente</option>
                    <option value="En preparacion">En preparacion</option>
                    <option value="Entregado">Entregado</option>

                </select>

                <button type="submit">Guardar pedido</button>
                <button type="button" id="cancelarpedido">Cancelar</button>

            </form>

        </div>
        <div class="contenedor-pedidos">

            <div class="columna-pedidos" id="pedidospendientes">

                <h2>Pendientes</h2>

                <div class="tarjeta-pedido">

                    <h3>Pedido #1</h3>

                    <p><strong>Cliente:</strong> <span class="cliente-pedido">Gahel Ulate</span></p>
                    <p><strong>Fecha:</strong> <span class="fecha-pedido">07/11/2026</span></p>
                    <p><strong>Estado:</strong> <span class="estado-pedido">Pendiente</span></p>
                    <p><strong>Empleado:</strong> <span class="empleado-pedido">Carlos Rodríguez</span></p>
                    <p><strong>Tipo:</strong> <span class="tipo-pedido">Para llevar</span></p>

                    <div class="acciones-pedido">
                        <button type="button" class="modificarpedido">Modificar</button>
                        <button type="button" class="eliminarpedido">Eliminar</button>
                    </div>

                </div>

            </div>

            <div class="columna-pedidos" id="pedidospreparacion">

                <h2>En preparación</h2>

                <div class="tarjeta-pedido">

                    <h3>Pedido #2</h3>

                    <p><strong>Cliente:</strong> <span class="cliente-pedido">Luis Carlos</span></p>
                    <p><strong>Fecha:</strong> <span class="fecha-pedido">07/11/2026</span></p>
                    <p><strong>Estado:</strong> <span class="estado-pedido">En preparación</span></p>
                    <p><strong>Empleado:</strong> <span class="empleado-pedido">María Fernández</span></p>
                    <p><strong>Tipo:</strong> <span class="tipo-pedido">En el restaurante</span></p>

                    <div class="acciones-pedido">
                        <button type="button" class="modificarpedido">Modificar</button>
                        <button type="button" class="eliminarpedido">Eliminar</button>
                    </div>

                </div>

            </div>

            <div class="columna-pedidos" id="pedidoscompletados">

                <h2>Completados</h2>

            </div>

        </div>
        <template id="plantillapedido">

            <div class="tarjeta-pedido">

                <h3></h3>

                <p><strong>Cliente:</strong> <span class="cliente-pedido"></span></p>
                <p><strong>Empleado:</strong> <span class="empleado-pedido"></span></p>
                <p><strong>Tipo:</strong> <span class="tipo-pedido"></span></p>
                <p><strong>Fecha:</strong> <span class="fecha-pedido"></span></p>
                <p><strong>Estado:</strong> <span class="estado-pedido"></span></p>

                <div class="acciones-pedido">
                    <button type="button" class="modificarpedido">Modificar</button>
                    <button type="button" class="eliminarpedido">Eliminar</button>
                </div>

            </div>

        </template>


        </div>
    </div>

    
    <script>

        const botonnuevo = document.getElementById("nuevopedido");
        const formulario = document.getElementById("formulariopedido");
        const botoncancelar = document.getElementById("cancelarpedido");
        const campoCliente = document.getElementById("clientepedido");
        const campoEmpleado = document.getElementById("empleadopedido");
        const campoTipo = document.getElementById("tipopedido");
        const campoEstado = document.getElementById("estadopedido");
        const pendientes = document.getElementById("pedidospendientes");
        const preparacion = document.getElementById("pedidospreparacion");
        const completados = document.getElementById("pedidoscompletados");

        let tarjetaSeleccionada = null;
        let siguienteId = 3;

        botonnuevo.addEventListener("click", function() {
            tarjetaSeleccionada = null;
            document.getElementById("registropedido").reset();
            formulario.style.display = "block";
        });
        botoncancelar.addEventListener("click", function() {
            formulario.style.display = "none";
            tarjetaSeleccionada = null;

        });
        
        document.getElementById("registropedido").addEventListener("submit", function(evento) {

            evento.preventDefault();

            const cliente = campoCliente.value;
            const empleado = campoEmpleado.value;
            const tipo = campoTipo.value;
            const estado = campoEstado.value;
            const fecha = new Date().toLocaleDateString("es-CR");

            if (tarjetaSeleccionada === null) {

                const plantilla = document.getElementById("plantillapedido");
                const tarjeta = plantilla.content.firstElementChild.cloneNode(true);

                tarjeta.querySelector("h3").textContent = "Pedido #" + siguienteId;
                tarjeta.querySelector(".cliente-pedido").textContent = cliente;
                tarjeta.querySelector(".empleado-pedido").textContent = empleado;
                tarjeta.querySelector(".tipo-pedido").textContent = tipo;
                tarjeta.querySelector(".fecha-pedido").textContent = fecha;
                tarjeta.querySelector(".estado-pedido").textContent = estado;

                if (estado === "Pendiente") {
                    pendientes.appendChild(tarjeta);

                } else if (estado === "En preparacion") {
                    preparacion.appendChild(tarjeta);

                } else {
                    completados.appendChild(tarjeta);

                }
                siguienteId++;
                alert("Pedido registrado correctamente.");

            }else {
                tarjetaSeleccionada.querySelector(".cliente-pedido").textContent = cliente;
                tarjetaSeleccionada.querySelector(".estado-pedido").textContent = estado;
                tarjetaSeleccionada.querySelector(".empleado-pedido").textContent = empleado;
                tarjetaSeleccionada.querySelector(".tipo-pedido").textContent = tipo;

                if (estado === "Pendiente") {
                    pendientes.appendChild(tarjetaSeleccionada);

                } else if (estado === "En preparación") {
                    preparacion.appendChild(tarjetaSeleccionada);

                } else {
                    completados.appendChild(tarjetaSeleccionada);
                }
                alert("Pedido modificado correctamente.");
            }
            formulario.style.display = "none";
            tarjetaSeleccionada = null;
        });

        
        document.querySelector(".contenedor-pedidos").addEventListener("click", function(evento) {

            if (evento.target.classList.contains("modificarpedido")) {
                const tarjeta = evento.target.closest(".tarjeta-pedido");
                tarjetaSeleccionada = tarjeta;
                const cliente = tarjeta.querySelector(".cliente-pedido").textContent;
                const estado = tarjeta.querySelector(".estado-pedido").textContent;
                campoCliente.value = cliente;
                campoEstado.value = estado;
                campoEmpleado.value = tarjeta.querySelector(".empleado-pedido").textContent;
                campoTipo.value = tarjeta.querySelector(".tipo-pedido").textContent;
                formulario.style.display = "block";
            }
            if (evento.target.classList.contains("eliminarpedido")) {
                    const tarjeta = evento.target.closest(".tarjeta-pedido");
                    const confirmar = confirm("¿Desea eliminar este pedido?");

                    if (confirmar) {

                        if (tarjetaSeleccionada === tarjeta) {
                            tarjetaSeleccionada = null;
                            formulario.style.display = "none";
                        }
                        tarjeta.remove();
                        alert("Pedido eliminado correctamente.");

                    }
                }
        });
        document.getElementById("buscarpedido").addEventListener("input", function() {

            const busqueda = this.value.toLowerCase();
            const tarjetas = document.querySelectorAll(".tarjeta-pedido");
            tarjetas.forEach(function(tarjeta) {
                const numero = tarjeta.querySelector("h3").textContent.toLowerCase();
                const cliente = tarjeta.querySelector(".cliente-pedido").textContent.toLowerCase();
                const estado = tarjeta.querySelector(".estado-pedido").textContent.toLowerCase();

                if (numero.includes(busqueda) || cliente.includes(busqueda) || estado.includes(busqueda)) {
                    tarjeta.style.display = "block";

                } else {
                    tarjeta.style.display = "none";
                }
            });
        });


    </script>


</body>
</html>
