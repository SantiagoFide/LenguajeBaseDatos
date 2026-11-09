
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Empleados - Comida Rápida EVY</title>
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

            <h1>Empleados</h1>
            <p>Administración de empleados del restaurante.</p>

            <div class="opciones">
                <input type="text" id="buscarempleado"placeholder="Buscar empleado">

                <button type="button" id="nuevoempleado">Nuevo empleado</button>
            </div>                
                <div class="formulario" id="formularioempleado">

                    <h2>Registrar nuevo empleado</h2>

                    <form id="registroempleado">

                        <label for="nombreempleado">Nombre completo</label>
                        <input type="text" id="nombreempleado" required>

                        <label for="telefonoempleado">Teléfono</label>
                        <input type="tel" id="telefonoempleado" required>

                        <label for="rolempleado">Rol</label>
                        <select id="rolempleado" required>
                            <option value="">Seleccione un rol</option>
                            <option value="Administrador">Administrador</option>
                            <option value="Cajero">Cajero</option>
                            <option value="Mesero">Mesero</option>
                        </select>

                        <button type="submit">Guardar empleado</button>
                        <button type="button" id="cancelarempleado">Cancelar</button>

                    </form>

                </div>
                <div class="contenedor-empleados" id="listaempleados">

                    <div class="tarjeta-empleado">

                        <div class="avatar-empleado">CR</div>

                        <h3>Carlos Rodríguez</h3>
                        <p class="rol-empleado">Cajero</p>

                        <div class="datos-empleado">
                            <p><strong>ID:</strong> 1</p>
                            <p><strong>Teléfono:</strong> <span class="telefono-empleado">8895-2412</span></p>
                        </div>

                        <div class="acciones-empleado">
                            <button type="button" class="modificarempleado">Modificar</button>
                            <button type="button" class="eliminarempleado">Eliminar</button>
                        </div>
                    
                    </div>

                    <template id="plantillaempleado">

                            <div class="tarjeta-empleado">

                                <div class="avatar-empleado"></div>

                                <h3></h3>
                                <p class="rol-empleado"></p>

                                <div class="datos-empleado">
                                    <p><strong>ID:</strong> <span class="id-empleado"></span></p>
                                    <p><strong>Teléfono:</strong> <span class="telefono-empleado"></span></p>
                                </div>

                                <div class="acciones-empleado">
                                    <button type="button" class="modificarempleado">Modificar</button>
                                    <button type="button" class="eliminarempleado">Eliminar</button>
                                </div>

                            </div>

                        </template>

                    <div class="tarjeta-empleado">

                        <div class="avatar-empleado">MF</div>

                        <h3>María Fernández</h3>
                        <p class="rol-empleado">Cocinera</p>

                        <div class="datos-empleado">
                            <p><strong>ID:</strong> 2</p>
                            <p><strong>Teléfono:</strong> <span class="telefono-empleado">8777-4321</span></p>
                        </div>

                        <div class="acciones-empleado">
                            <button type="button" class="modificarempleado">Modificar</button>
                            <button type="button" class="eliminarempleado">Eliminar</button>
                        </div>

                    </div>

                </div>

        </div>
    </div>
    
    <script>

        const botonnuevo = document.getElementById("nuevoempleado");
        const formulario = document.getElementById("formularioempleado");
        const botoncancelar = document.getElementById("cancelarempleado");
        const campoNombre = document.getElementById("nombreempleado");
        const campoTelefono = document.getElementById("telefonoempleado");
        const campoRol = document.getElementById("rolempleado");
        const listaEmpleados = document.getElementById("listaempleados");

        let tarjetaSeleccionada = null;
        let siguienteId = 3;

        botonnuevo.addEventListener("click", function() {

        tarjetaSeleccionada = null;

        document.getElementById("registroempleado").reset();

        formulario.style.display = "block";

    });

    botoncancelar.addEventListener("click", function() {

        formulario.style.display = "none";
        tarjetaSeleccionada = null;

    });

    
    listaEmpleados.addEventListener("click", function(evento) {

        if (evento.target.classList.contains("modificarempleado")) {

            const tarjeta = evento.target.closest(".tarjeta-empleado");

            tarjetaSeleccionada = tarjeta;

            const nombre = tarjeta.querySelector("h3").textContent;
            const telefono = tarjeta.querySelector(".telefono-empleado").textContent;
            const rol = tarjeta.querySelector(".rol-empleado").textContent;

            campoNombre.value = nombre;
            campoTelefono.value = telefono;
            campoRol.value = rol;

            formulario.style.display = "block";

        }

        if (evento.target.classList.contains("eliminarempleado")) {

            const tarjeta = evento.target.closest(".tarjeta-empleado");

            const confirmar = confirm("¿Desea eliminar este empleado?");

            if (confirmar) {

                if (tarjetaSeleccionada === tarjeta) {
                    tarjetaSeleccionada = null;
                    formulario.style.display = "none";
                }

                tarjeta.remove();

                alert("Empleado eliminado correctamente.");

            }
        }

    });
    document.getElementById("registroempleado").addEventListener("submit", function(evento) {

        evento.preventDefault();

        const nombre = campoNombre.value.trim();
        const telefono = campoTelefono.value.trim();
        const rol = campoRol.value;

        const iniciales = nombre.split(/\s+/)
            .slice(0, 2)
            .map(function(palabra) {
                return palabra.charAt(0).toUpperCase();
            })
            .join("");

        if (tarjetaSeleccionada === null) {

            const plantilla = document.getElementById("plantillaempleado");

            const tarjeta = plantilla.content.firstElementChild.cloneNode(true);

            tarjeta.querySelector(".id-empleado").textContent = siguienteId;
            tarjeta.querySelector(".avatar-empleado").textContent = iniciales;
            tarjeta.querySelector("h3").textContent = nombre;
            tarjeta.querySelector(".rol-empleado").textContent = rol;
            tarjeta.querySelector(".telefono-empleado").textContent = telefono;

            listaEmpleados.appendChild(tarjeta);

            siguienteId++;

            alert("Empleado registrado correctamente.");

        } else {

            tarjetaSeleccionada.querySelector(".avatar-empleado").textContent = iniciales;
            tarjetaSeleccionada.querySelector("h3").textContent = nombre;
            tarjetaSeleccionada.querySelector(".rol-empleado").textContent = rol;
            tarjetaSeleccionada.querySelector(".telefono-empleado").textContent = telefono;

            alert("Empleado modificado correctamente.");

        }

        formulario.style.display = "none";
        tarjetaSeleccionada = null;

    });
    document.getElementById("buscarempleado").addEventListener("input", function() {

        const busqueda = this.value.toLowerCase();
        const tarjetas = listaEmpleados.querySelectorAll(".tarjeta-empleado");

        tarjetas.forEach(function(tarjeta) {

            const id = tarjeta.querySelector(".datos-empleado p").textContent.toLowerCase();
            const nombre = tarjeta.querySelector("h3").textContent.toLowerCase();
            const rol = tarjeta.querySelector(".rol-empleado").textContent.toLowerCase();

            if (id.includes(busqueda) || nombre.includes(busqueda) || rol.includes(busqueda)) {
                tarjeta.style.display = "";
            } else {
                tarjeta.style.display = "none";
            }

        });

    });



    </script>

</body>
</html>
