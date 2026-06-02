# Análisis de código — LojaReport

**Nombre:** Osyual Yoel Macas Montoya  
**Branch:** Osyual-Macas  
**Fecha:** 1 de jun de 2026     
**Repositorio base:** https://github.com/richardmijo/eva_loja_reporta.git

## Pregunta 1 — StatelessWidget vs StatefulWidget

### 1a) ¿DetailScreen necesita ser StatefulWidget?

Realmente no. Si revisamos a fondo el archivo `detail_screen.dart`, casi toda la información (título, descripción, tipo, zona) viene de los argumentos de navegación (`ModalRoute...`). Es decir, son datos de solo lectura. El único dato que muta internamente es `bool favorito = false`. Técnicamente, esto obliga a usar un `StatefulWidget` para actualizar el icono al tocarlo. Sin embargo, mantenerlo como StatefulWidget solo se justificaría si estuviéramos 100% de acuerdo en que ese "favorito" es totalmente efímero y está bien que se pierda, lo cual es una pésima experiencia de usuario. El costo de recursos de un StatefulWidget no vale la pena para algo tan mal diseñado.

### 1b) El estado problemático

El problema es la variable `bool favorito = false` (línea 12).
El flujo paso a paso es así: 1) Abres el incidente y arranca en `false`. 2) Lo marcas como favorito y el `setState` lo cambia visualmente. 3) Haces un pop para regresar a la lista (`HomeScreen`). 
Aquí está la falla: la lista no se entera de nada, y como la pantalla de detalle se destruye de la memoria, si vuelves a entrar al mismo incidente, el icono volverá a estar desmarcado porque la variable renace en `false`. No hay un estado global que sobreviva.

### 1c) ¿Qué cambiarías y por qué?

Haría lo siguiente:
1. Cambiaría la pantalla a un `StatelessWidget`, borrando todo el código del `_DetailScreenState` y los `setState`.
2. Para que el favorito persista, lo manejaría en un estado global (Provider/Bloc). Otra opción intermedia y más ligera sería devolver el valor al salir usando `Navigator.pop(context, favorito)` para que Home reciba el cambio sin montar un Provider gigante.
3. Pasaría los datos del incidente por el constructor en vez de usar `ModalRoute` en el `build`. 
Esto mejora el diseño porque delegamos los datos a quien corresponde y dejamos que esta pantalla solo pinte la interfaz.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

Literalmente hace de todo (es el típico anti-patrón "God Widget"). Aquí listé 7 responsabilidades mezcladas:
1. **Red:** Llama a `_dio.get(...)` directo en la vista.
2. **Estado:** Controla a mano `cargando`, `error` e `incidentes`.
3. **Filtrado:** El getter `incidentesFiltrados` contiene la lógica de negocio.
4. **Mapeo visual:** `_buildTarjetaIncidente` decide colores e iconos (líneas 157-203), lo cual debería ser un widget aparte.
5. **Navegación:** Decide a dónde ir a `/about` y `/detail`.
6. **Eventos:** Llama a recargar con los botones Retry y el FAB.
7. **Side effects:** Modifica el `contadorRebuild++` dentro del `build()`.
Además, hay un bug gravísimo: hace `setState` después del `await` de red sin revisar `if (!mounted)`. Si sales antes de cargar, la app colapsa.

### 2b) El problema de tener Dio dentro del widget

Tenemos dos instancias de Dio (en la línea 10 de ambas pantallas). Curiosamente, la de `detail_screen.dart` **ni siquiera se usa en todo el archivo**, está de puro adorno por copiar y pegar.
Tener la red descentralizada significa desperdicio de recursos, dificultad masiva para hacer tests unitarios, y que los timeouts quedan inconsistentes. Si mañana cambian la URL o exigen un Token JWT, tendríamos que ir archivo por archivo.

### 2c) Lo que no debería estar en build()

En la línea 57 hay un `contadorRebuild++;` directo en el método `build()`.
El `build` en Flutter se ejecuta de forma incontrolable docenas de veces (animaciones, scroll, etc.). Modificar variables aquí genera comportamientos raros y ensucia la vista. Para corregirlo, si de verdad solo queremos monitorear los rebuilds, deberíamos usar `debugPrint` o un observer. Cualquier lógica real debería moverse a eventos de usuario o al `initState`/`didUpdateWidget`.

### 2d) Diseña la solución: cómo reorganizarías el código

Organizaría el código en este árbol de carpetas y capas:
- `lib/core/network/dio_client.dart` -> **ApiClient:** Configura Dio una sola vez (baseUrl, timeouts).
- `lib/models/incident.dart` -> **Modelo:** Datos limpios y tipados.
- `lib/repositories/incident_repository.dart` -> **Datos:** Llama a la API y devuelve listas de modelos.
- `lib/providers/home_provider.dart` -> **Estado:** Llama al Repositorio, guarda listas, maneja filtros y carga.
- `lib/screens/home_screen.dart` -> **UI:** Solo observa al Provider y arma la pantalla.
Además, extraería las tarjetas visuales pesadas a `lib/widgets/incident_card.dart` y `filter_bar.dart` para no ensuciar el código del Home.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Se pasa un frágil `Map<String, dynamic>`.
Aquí hay dos riesgos inminentes:
1. **Crash por Null Safety:** Usan `!`. Si la pantalla se abre desde un deep link sin datos, la app truena con `Null check operator...`.
2. **Crash Silencioso de Lógica:** No hay seguridad de tipos. Por ejemplo, en la línea 52 del detalle. Si el backend mañana cambia la llave `'status'` por `'state'`, la evaluación `incidente['status'] == 'resolved'` fallará en silencio. Visualmente, los incidentes resueltos se pintarán de color naranja y el texto del status quedará vacío.

### 3b) El botón que hace algo cuestionable

El botón "Back to home" usa `Navigator.pushNamed(context, '/');`.
En vez de retroceder (pop), esto empuja un nuevo Home encima del detalle. Esto genera efectos extra catastróficos: cada nuevo Home llama otra vez a su `initState()`, lo que dispara peticiones HTTP duplicadas y totalmente innecesarias. Si lo presionas varias veces, tu stack concreto queda así: `[Home, Detail, Home, Detail, Home]`, consumiendo recursos y rompiendo el botón físico de atrás en Android.

### 3c) ¿Cómo mejorarías el paso de datos?

Dejaría de usar Mapas y pasaría al modelo `Incident`:

```dart
class Incident {
  final String id;
  // ...
  factory Incident.fromJson(Map<String, dynamic> json) { ... }
}
```
Otra opción aún mejor para proyectos escalables sería pasar **solo el `incident.id`** en la navegación y que la pantalla de detalle lo cargue fresco desde el Repositorio. Además, en la recepción pondría una pantalla de error por si el argumento que llega no es válido.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Hay dos. Repito, una de ellas (en Detail) es código muerto y la otra está en Home. 
No centralizar esto hace imposible tener un lugar único para implementar el refresco global de tokens de expiración, o para cancelar peticiones (cancel tokens) cuando se sale de una pantalla de forma abrupta.

### 4b) ¿Qué le falta a la configuración actual de Dio?

Le faltan pilares para producción:
1. **Falta configurar la `baseUrl`** para no quemarla en cada `.get()`.
2. **Timeouts concretos:** Poner `connectTimeout` de unos 10-15 segundos, y saber diferenciar errores (timeout vs 404 vs 500 vs sin red).
3. **Manejo completo de errores:** Hay un bug concreto en las líneas 36-41 de `home_screen.dart`: como solo comprueban `if (statusCode == 200)` pero **no tienen un bloque `else`**, si la API falla con un 404 o 500 sin explotar, la variable `cargando` se queda en `true` para siempre. También faltaría enviar el header `Content-Type: application/json`.

### 4c) Diseña cómo centralizarías Dio para toda la app

En el archivo `dio_client.dart` configuraría el cliente con sus `BaseOptions` (URL y timeouts) y le agregaría un `LogInterceptor` de inmediato para poder ver todos los requests en consola en desarrollo.
Este `DioClient` lo instanciaría como Singleton o lo proveería vía Provider (para facilitar los tests unitarios). Las pantallas no verían a Dio; el Repositorio usaría este cliente inyectado y el Home usaría el Repositorio.

---

## Resumen de cambios a implementar

Estos son los cambios clave priorizados:

1. **Centralizar Dio** en `lib/core/network/dio_client.dart` (con LogInterceptor y timeouts), borrando el Dio muerto del detalle y exponiéndolo vía Provider para testing.
2. **Crear el modelo `Incident`** y el `IncidentRepository` para sacar las llamadas HTTP de las vistas.
3. **Implementar el `HomeProvider`** para manejar el estado y arreglar el bug de `cargando` infinito (status != 200) y del `!mounted`.
4. **Extraer UI pesada:** Separar el `IncidentCard` y el `FilterBar` en widgets independientes.
5. **Arreglar Navegación:** Convertir ambas vistas a `StatelessWidget`. Pasar el objeto tipado `Incident` (o solo el ID) y reemplazar el efecto duplicador de `pushNamed` por una alternativa como `Navigator.pop(context, favorito)`.
