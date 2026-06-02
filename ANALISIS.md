# Análisis de código — LojaReport

**Nombre:** <!-- Eduardo Gabbriel Pardo Dávila -->  
**Branch:** <!-- analisis/Eduardo-Pardo-->  
**Fecha:** <!-- 01-06-2026-->  
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

Sí, porque actualmente tiene una variable llamada favorito que cambia cuando el usuario presiona el botón de marcador. Para actualizar la interfaz utiliza setState(), por eso necesita ser un StatefulWidget.

### 1b) El estado problemático

El problema es la variable favorito. Aunque cambia visualmente cuando se presiona el botón, el valor no se guarda en ningún lado. Si el usuario sale de la pantalla y vuelve a entrar, el favorito se pierde.

### 1c) ¿Qué cambiarías y por qué?

Si la opción de favoritos no es necesaria, convertiría DetailScreen en un StatelessWidget porque solo muestra información. Si se quiere mantener la funcionalidad, guardaría los favoritos en una base de datos o almacenamiento local para que no se pierdan.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

_HomeScreenState hace muchas cosas al mismo tiempo:

Consume la API con Dio.
Guarda los incidentes.
Maneja errores y estados de carga.
Filtra los datos.
Construye la interfaz.
Navega a otras pantallas.


### 2b) El problema de tener Dio dentro del widget

El problema es que la pantalla queda directamente conectada con la API. Si mañana cambia la URL o la forma de consumir los datos, habría que modificar la pantalla. Además, el código es más difícil de mantener.

### 2c) Lo que no debería estar en build()

Dentro de build() no debería existir lógica que no esté relacionada con la interfaz. Por ejemplo:

contadorRebuild++;

Este contador se ejecuta cada vez que Flutter reconstruye la pantalla y realmente no aporta nada al funcionamiento de la aplicación.

### 2d) Diseña la solución: cómo reorganizarías el código

Crearía una clase llamada IncidentService para encargarse de las consultas a la API y una clase Incident para representar los datos de un incidente. De esta forma HomeScreen solo se encargaría de mostrar la información en pantalla y no de obtenerla directamente.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Actualmente se pasa un Map<String, dynamic>. El problema es que no existe control de tipos y si una clave cambia de nombre o no existe, el error aparecerá cuando la aplicación se esté ejecutando.

### 3b) El botón que hace algo cuestionable

El botón "Back to home" utiliza:

Navigator.pushNamed(context, '/');

Esto crea una nueva pantalla de inicio en lugar de regresar a la anterior. Lo correcto sería usar:

Navigator.pop(context);

### 3c) ¿Cómo mejorarías el paso de datos?
Crearía una clase Incident con atributos como título, zona, estado y descripción. Así se enviaría un objeto completo entre pantallas en lugar de un mapa genérico, haciendo el código más seguro y fácil de mantener.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Existen dos instancias de Dio, una en HomeScreen y otra en DetailScreen. Además, la de DetailScreen ni siquiera se utiliza. Esto genera código innecesario y dificulta centralizar la configuración.

### 4b) ¿Qué le falta a la configuración actual de Dio?

Le faltan configuraciones importantes como:

URL base centralizada.
Tiempo de espera (timeout).
Manejo global de errores.
Interceptores para registrar peticiones y respuestas.

### 4c) Diseña cómo centralizarías Dio para toda la app

Crearía una clase llamada ApiClient que tenga una sola instancia de Dio configurada. Luego los servicios utilizarían esa instancia para hacer las peticiones. Así, si en el futuro hay que cambiar algo de la configuración, solo se modifica en un lugar.

---

## Resumen de cambios que implementarás el miércoles

1. Crear una clase Incident para evitar el uso de Map<String, dynamic>.
2. Crear un servicio para separar las consultas a la API de las pantallas.
3. Centralizar la configuración de Dio en una sola clase.
4. Cambiar el botón de regreso para que use Navigator.pop() en lugar de crear una nueva pantalla de inicio.
