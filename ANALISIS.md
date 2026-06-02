# Análisis de código — LojaReport

**Nombre:** Malena Jovanna Orbea Urgiles  
**Branch:** analisis/malena-orbea  
**Fecha:** 1 de junio de 2026  
**Repositorio base:** https://github.com/richardmijo/eva_loja_reporta.git

---

## Instrucciones

Responde cada pregunta directamente en este archivo usando Markdown.  
Sé específico — menciona el archivo y el método del que hablas.  
Una respuesta genérica que podría aplicar a cualquier app Flutter no sirve.  
Cuando termines, haz push de tu branch y publica la URL en Canvas.

---

## Pregunta 1 — StatelessWidget vs StatefulWidget

### 1a) ¿DetailScreen necesita ser StatefulWidget?

**No.** Al revisar `detail_screen.dart`, se observa que el widget solo recibe datos estáticos del incidente a través de su constructor para renderizarlos en la interfaz. No implementa animaciones manuales cronometradas, manejo de formularios dinámicos ni ciclos de vida complejos que justifiquen la persistencia de un objeto `State`. Mantenerlo como `StatefulWidget` genera código repetitivo (*boilerplate*) e innecesario.

### 1b) El estado problemático

El único estado interactivo de la pantalla se encuentra en el botón inferior para cambiar el estado del incidente (marcarlo como "Atendido").
* **El problema:** Se maneja como una variable mutativa local dentro de `_DetailScreenState`. Cuando el usuario presiona el botón de retroceso nativo y sale de la pantalla, **este estado se destruye por completo**. Al volver a entrar al mismo incidente, vuelve a su valor inicial.
* **HomeScreen:** No tiene ninguna forma de conocer este cambio, provocando que la lista principal de incidentes se desincronice de la realidad de los datos.

### 1c) ¿Qué cambiarías y por qué?

1. **Transformar `DetailScreen` en `StatelessWidget`:** Eliminar la clase interna `_DetailScreenState` para limpiar el árbol de widgets y mejorar el rendimiento de renderizado.
2. **Aplicar Levantamiento de Estado (*State Lifting*):** Definir una función callback (`ValueChanged` o `VoidCallback`) en el constructor de `DetailScreen`.
3. **Mover la lógica:** El botón del detalle disparará este callback, delegando la responsabilidad de actualizar el estado a la capa superior (donde reside la lista global), logrando que el cambio sea persistente.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

Actualmente sufre del antipatrón de la **Clase Dios**, centralizando demasiadas tareas en un solo lugar:
* **Renderizado de Interfaz:** Construir los widgets de la lista y los botones de filtro. *(Correcto)*.
* **Consumo de Red (HTTP):** Instanciar el cliente `Dio` y disparar las solicitudes asíncronas a los endpoints. *(Incorrecto: Debe delegarse a un servicio de red dedicado)*.
* **De-serialización de datos:** Recibir las respuestas crudas en `Map` o `List` y parsearlas directamente dentro del widget. *(Incorrecto: Pertenece a un modelo de datos dedicado)*.
* **Lógica de negocio:** Procesar el filtrado en tiempo de ejecución de los incidentes según la categoría seleccionada. *(Incorrecto: Debe abstraerse en un controlador de estado)*.

### 2b) El problema de tener Dio dentro del widget

Instanciar y configurar `Dio` directamente dentro del código del widget acarrea problemas críticos de escalabilidad:
* **Duplicación de código:** Forzaría a copiar y pegar las cabeceras (*headers*), tokens de sesión y configuraciones idénticas en cada pantalla de la app.
* **Acoplamiento rígido:** Si se modifica la URL base del servidor de pruebas, se deben alterar múltiples archivos en lugar de un único punto centralizado.
* **Inviabilidad de Pruebas:** Impide la inyección de dependencias simuladas (*mocking*) para testear la UI de forma aislada sin acceso real a internet.

### 2c) Lo que no debería estar en build()

Dentro del método `build()` se detectan cálculos iterativos pesados de filtrado y ordenamiento de listas de incidentes cada vez que ocurre un redibujado. El método `build()` debe ser una función pura de diseño visual. Al ejecutarse de manera iterativa ante cualquier cambio menor del árbol de widgets, saturar esta función con lógica pesada degrada los frames por segundo, produciendo congelamientos visuales (*jank*).

### 2d) Diseña la solución: cómo reorganizarías el código

Propongo segmentar la solución estructurando el proyecto bajo una arquitectura modular limpia por capas:
* **Capa de Modelo (`IncidenteModel`):** Clase de Dart inmutable con un constructor de-serializador `.fromJson()` para asegurar el tipado fuerte.
* **Capa de Red (`ApiClient`):** Una clase configurada como *Singleton* para mantener una única instancia globalizada de `Dio`.
* **Capa de Repositorio (`IncidenteRepository`):** Clase encargada de conectar el `ApiClient`, capturar errores HTTP y mapear las respuestas crudas en listas de `IncidenteModel`.
* **Capa de Presentación:** Reducir `HomeScreen` y `DetailScreen` a estructuras que solo reciban los datos procesados desde un controlador encargado del manejo de estados de la UI.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Se realiza la transferencia de datos mediante un mapa dinámico sin tipar (`Map<String, dynamic>`) inyectado en el parámetro de argumentos de la ruta de navegación.  
**Riesgo real en ejecución:** Carece de validación en tiempo de compilación. Si el backend modifica el nombre de una clave del JSON (por ejemplo, de `titulo_incidente` a `title`), el compilador de Dart no detectará el fallo. Al presionar el incidente, la aplicación fallará inmediatamente en producción con una excepción por asignación de nulos (`Null check operator used on a null value`).

### 3b) El botón que hace algo cuestionable

En la pantalla de detalle, el botón para regresar o redirigir a la vista inicial utiliza el método `Navigator.pushNamed(context, '/home')`.  
**Efecto en el stack:** En lugar de liberar la memoria cerrando la pantalla actual con un `.pop()`, el método `pushNamed` **apila una nueva e independiente instancia** de `HomeScreen` sobre el detalle. Si se presiona iterativamente, satura la pila de navegación de forma infinita (`Home -> Detail -> Home -> Detail`), lo que provoca fugas de memoria críticas y corrompe por completo el comportamiento del botón físico de retroceso del dispositivo.

### 3c) ¿Cómo mejorarías el paso de datos?

Sustituir el mapa dinámico por el envío estructurado de un objeto inmutable de Dart:

```dart
class IncidenteModel {
  final int id;
  final String titulo;
  final String descripcion;

  IncidenteModel({required this.id, required this.titulo, required this.descripcion});

  factory IncidenteModel.fromJson(Map<String, dynamic> json) {
    return IncidenteModel(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}