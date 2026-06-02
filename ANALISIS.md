# Análisis de código — LojaReport

**Nombre:** Luis Eduardo Poma Medina 
**Branch:** analisis/Luis-Poma
**Fecha:** 01 / 06 / 2026
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

Sí y no: en el estado actual (`lib/screens/detail_screen.dart`) `DetailScreen` mantiene la variable `favorito` y un `Dio _dio = Dio()` dentro de `_DetailScreenState`.

- Si solo se necesita mostrar datos inmutables del incidente (recibidos por argumento) y no hay interacción con red ni estado local persistente, podría ser `StatelessWidget`.
- Sin embargo, como actualmente hay un booleano `favorito` que se cambia con `setState`, necesita `StatefulWidget` si se mantiene ese comportamiento en UI local.

Conclusión práctica: conservar `StatefulWidget` solo si el toggle de favorito se gestiona localmente en la pantalla; en caso contrario trasladar ese estado a un servicio/Provider y convertir la pantalla en `StatelessWidget`.

### 1b) El estado problemático

Problemas concretos en `lib/screens/detail_screen.dart`:

- La instancia `final Dio _dio = Dio();` está dentro de `_DetailScreenState` pero no se usa. Tener clientes HTTP dentro de un `State` mezcla responsabilidades (UI + acceso a red) y dificulta pruebas.
- El incidente se obtiene via `ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>`: usar `Map` sin tipado es frágil y propenso a errores en tiempo de ejecución.
- El `favorito` se guarda solo en memoria local; si la intención es persistir o compartir ese estado, la implementación actual no es adecuada.

### 1c) ¿Qué cambiarías y por qué?

Cambios recomendados (específicos):

- Eliminar la instancia `Dio` de `_DetailScreenState`. Si la pantalla necesita hacer peticiones (e.g., marcar favorito en servidor), delegar a un servicio centralizado (`ApiService`) y no al widget.
- Introducir un modelo tipado `Incident` en `lib/models/incident.dart` y cambiar la firma de navegación para pasar `Incident` o un `id` en vez de `Map<String,dynamic>`.
- Si el estado `favorito` debe persistir o compartirse, crear un `FavoritesService` (o usar Provider/ChangeNotifier) que exponga métodos `isFavorite(id)` / `toggleFavorite(id)`; entonces la pantalla puede ser `Stateless` y leer/escuchar ese servicio.

Razonamiento: separar UI de lógica de red/estado mejora testabilidad, reduce duplicación y evita tener clientes HTTP sin control en widgets.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

En `lib/screens/home_screen.dart` `_HomeScreenState` actualmente:

- Gestiona la instancia de `Dio` (`final Dio _dio = Dio()`).
- Realiza la carga de datos desde la API (`cargarIncidentes`).
- Mantiene el estado de la UI: `incidentes`, `cargando`, `error`, `filtro`.
- Implementa la lógica de filtrado (`incidentesFiltrados`) y construcción de la UI (`_buildBarraFiltros`, `_buildTarjetaIncidente`, etc.).

Es decir: mezcla acceso a datos, lógica de negocio y presentación.

### 2b) El problema de tener Dio dentro del widget

Problemas concretos:

- Crea múltiples instancias potenciales y configuración inconsistente (timeout, interceptors, auth) si se usa en más widgets.
- Dificulta las pruebas unitarias y la inyección de dependencias (no puedes mockear fácilmente el cliente desde fuera).
- Viola separación de responsabilidades: el widget debe encargarse de UI, no de crear/configurar clientes HTTP.

### 2c) Lo que no debería estar en build()

En `build()` no deberían ejecutarse operaciones de I/O, lógica pesada, ni cambiar el estado salvo para renderizado. Específicamente:

- Llamadas de red (no llamar a `cargarIncidentes` en `build`).
- Operaciones de parsing o transformación costosa de datos.
- Creación/ configuración de clientes o servicios (Dio, repositorios).

`build()` debe ser puro respecto al árbol de widgets: leer el estado y construir UI.

### 2d) Diseña la solución: cómo reorganizarías el código

Reorganización propuesta (con rutas y archivos concretos):

1. Models
	- `lib/models/incident.dart` → clase `Incident` con campos (`id`, `title`, `type`, `zone`, `description`, `status`, ... ) y `fromJson`/`toJson`.

2. Servicios / API
	- `lib/services/api_service.dart` → clase `ApiService` con un `Dio` inyectado en el constructor y métodos:
	  - `Future<List<Incident>> fetchIncidents()`
	  - `Future<Incident> fetchIncident(String id)` (opcional)

3. Repositorio
	- `lib/repositories/incident_repository.dart` → clase `IncidentRepository` que usa `ApiService` y encapsula transformaciones y caché.

4. Estado / Provider
	- `lib/providers/incident_provider.dart` → `ChangeNotifier` (o equivalente) con propiedades: `List<Incident> incidents`, `bool loading`, `String error`, `String filtro`; métodos `load()`, `setFiltro()`, `refresh()`.

5. Widgets
	- `HomeScreen` → convertir a `StatelessWidget`, leer `IncidentProvider` (Provider/Consumer) y construir UI según el estado.
	- `DetailScreen` → recibir `Incident` (o leerlo desde Provider si se pasa `id`).

Conexión: Registrar `ApiService`/`IncidentRepository` en el inicio (por ejemplo con `GetIt` o mediante `MultiProvider`) y exponer `IncidentProvider` para los widgets.

Beneficio: tests más sencillos, un único lugar para configurar `Dio`, y separación clara entre UI y lógica de negocio.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Se pasa un `Map<String, dynamic>` en `Navigator.pushNamed(context, '/detail', arguments: incidente)` (ver `lib/screens/home_screen.dart`). Riesgos:

- Falta de tipado: cambios en la API o claves mal escritas provocan errores en tiempo de ejecución.
- Difícil refactorización y menos autocompletado/seguridad en IDE.

### 3b) El botón que hace algo cuestionable

En `lib/screens/detail_screen.dart` el botón al final hace `Navigator.pushNamed(context, '/')` para volver al home. Eso empuja otra instancia de la pantalla de inicio sobre la pila en lugar de hacer `Navigator.pop(context)`. Resultado: crecimiento innecesario del stack y comportamiento inesperado al navegar.

### 3c) ¿Cómo mejorarías el paso de datos?

Mejoras concretas:

- Definir modelo `Incident` (`lib/models/incident.dart`):

```dart
class Incident {
	final String id;
	final String title;
	final String type;
	final String zone;
	final String status;
	final String description;

	Incident({required this.id, required this.title, required this.type, required this.zone, required this.status, required this.description});

	factory Incident.fromJson(Map<String, dynamic> json) => Incident(
		id: json['id'].toString(),
		title: json['title'] ?? '',
		type: json['type'] ?? '',
		zone: json['zone'] ?? '',
		status: json['status'] ?? '',
		description: json['description'] ?? '',
	);
}
```

- Pasar instancias `Incident` en `arguments` o, mejor, pasar solo `id` y que `DetailScreen` solicite el incidente al repositorio/provider si se quiere recargar desde la fuente autorizada.
- Cambiar la navegación de regreso en `DetailScreen` a `Navigator.pop(context)`.

Esto ofrece tipado, facilita la refactorización y permite recarga selectiva si se pasa solo `id`.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

En el código visible hay al menos 2 instancias directas de `Dio`: una en `_HomeScreenState` (`lib/screens/home_screen.dart`) y otra en `_DetailScreenState` (`lib/screens/detail_screen.dart`).

Problemas:
- Configuración inconsistente entre instancias (timeouts, headers, interceptors).
- Duplicación de recursos y dificultad para añadir comportamientos transversales (auth, logging, retries).
- Difícil de mockear en tests.

### 4b) ¿Qué le falta a la configuración actual de Dio?

Le falta:

- `BaseOptions` con `baseUrl`, `connectTimeout`/`receiveTimeout`.
- Interceptors para manejo de errores, logging y autenticación (si aplica).
- Mecanismo de reintentos o backoff para fallos transitorios.
- Manejo centralizado de conversiones (parsers) y mapeo a modelos.

### 4c) Diseña cómo centralizarías Dio para toda la app

Estructura propuesta para centralizar `Dio`:

- `lib/services/api_client.dart`
	- Clase `ApiClient` que expone una instancia de `Dio` configurada en el constructor con `BaseOptions(baseUrl: 'https://...', connectTimeout: ...)`.
	- Registra interceptors: `AuthInterceptor`, `LoggingInterceptor`, `ErrorInterceptor`.

- `lib/services/api_service.dart`
	- Clase `ApiService` que recibe `ApiClient` e implementa métodos HTTP de alto nivel (`get`, `post`, etc.) devolviendo JSON o modelos.

- Inyección / registro:
	- Registrar `ApiClient` y `ApiService` en el arranque de la app con `GetIt` o como `Provider` en `main.dart`.

- Uso:
	- `IncidentRepository` usa `ApiService` para obtener datos.
	- Los widgets consumen `IncidentProvider`/`Repository` y no acceden directamente a `Dio`.

Beneficio: una sola fuente de verdad para todas las peticiones, configuración consistente y puntos únicos para monitorización y retries.

---

## Resumen de cambios que implementarás el miércoles

<!-- Lista los cambios concretos que vas a hacer el jueves, en orden de prioridad.
Esto es un compromiso: si el jueves tu código va en otra dirección, debes justificarlo. -->

1. Refactorizar la capa de red: crear `ApiClient`/`ApiService` centralizado y mover todas las llamadas a él (prioridad alta).
2. Introducir el modelo `Incident` y `IncidentRepository` + `IncidentProvider` (ChangeNotifier) — mover `cargarIncidentes` fuera de `HomeScreen` (prioridad alta).
3. Corregir la navegación y el paso de datos: pasar `Incident`/`id` en lugar de `Map` y usar `Navigator.pop` en `DetailScreen` (prioridad media).
4. Extraer la lógica de favoritos a un servicio/Provider y eliminar `Dio` no usado en `DetailScreen` (prioridad media/baja).
