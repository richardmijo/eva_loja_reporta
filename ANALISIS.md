# Análisis de código — LojaReport

**Nombre:** Jhandry Becerra  
**Branch:** analisis/jhandry-becerra  
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

No, definitivamente no necesita ser StatefulWidget. Mirando el archivo `detail_screen.dart`, la pantalla casi no hace nada que requiera mantener estado interno. Solo muestra datos que recibe por parámetro desde `HomeScreen`.

Lo único que cambia es el boolean `favorito` (línea 11 en `detail_screen.dart`), que indica si el incidente está marcado como favorito. Ese cambio se maneja con `setState(() => favorito = !favorito)` en el `onPressed` del botón bookmark (línea 28). Pero el problema es que ese estado no persiste, no se guarda en una base de datos ni en SharedPreferences, así que apenas el usuario navega hacia atrás, ese estado se pierde.

Si realmente necesitara mantener favoritos, eso no debería estar en el widget de detalle. El widget podría ser perfectamente stateless y solo mostrar lo que le pasan como argumentos.

### 1b) El estado problemático

El estado problemático es exactamente la variable `bool favorito = false` de la línea 11 en `detail_screen.dart`. 

Cuando el usuario presiona el ícono de bookmark para marcar algo como favorito, se ejecuta `setState(() => favorito = !favorito)`. Si pasa esto, el ícono cambia de bookmark_border a bookmark. Pero aquí está el problema: cuando el usuario presiona el botón "Back to home" (línea 65 en `detail_screen.dart`), se ejecuta `Navigator.pushNamed(context, '/')`, que navega a la pantalla inicial.

Cuando el usuario vuelve a seleccionar el mismo incidente desde la lista de `HomeScreen`, una **nueva instancia** de `DetailScreen` se crea. Y cuando una nueva instancia se crea, `favorito` vuelve a inicializarse en `false`. El cambio que hizo el usuario simplemente desapareció.

Además, `HomeScreen` no sabe nada de ese cambio. No hay sincronización. Si el usuario marcase un incidente como favorito en la pantalla de detalle, eso no se refleja en la lista de incidentes de la pantalla anterior, ni se persiste en ningún lado.

### 1c) ¿Qué cambiarías y por qué?

Cambiaría `DetailScreen` de `StatefulWidget` a `StatelessWidget`. Los cambios concretos serían:

1. **Eliminar `_DetailScreenState`**: El widget sería directo, sin state class.

2. **Eliminar la variable `favorito`**: No la necesita. Si en el futuro se decide implementar favoritos de verdad, eso debería ser:
   - Un servicio o repositorio que persista favoritos (base de datos, SharedPreferences, o el API)
   - Manejado desde `HomeScreen` (que es el que mantiene la lista de incidentes)
   - Pasado a `DetailScreen` solo como un parámetro de lectura

3. **Reemplazar el botón de favorito**: En lugar de togglear estado local, podría:
   - Mostrar un botón deshabilitado (disabled) indicando que la feature no está implementada
   - O, si se implementa, que el `onPressed` haga una llamada a un servicio de favoritos y maneje la respuesta desde HomeScreen

4. **Eliminar `Dio` de esta pantalla**: La línea 10 (`final Dio _dio = Dio();`) no se usa en ningún lado. Debería eliminarse.

El resultado es que `DetailScreen` se convierte en una pantalla **de solo lectura**: recibe datos, los muestra, y listo. Es más simple, más predecible, y más fácil de testear.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

`_HomeScreenState` (en `home_screen.dart`) tiene muchas responsabilidades, demasiadas en realidad:

1. **Configurar Dio y hacer peticiones HTTP** (línea 10: `final Dio _dio = Dio();`, línea 24 en `cargarIncidentes()`)
   - Esto debería estar en un servicio de API separado. El widget no debería saber cómo conectarse al servidor.

2. **Gestionar el ciclo de vida y cargar datos iniciales** (línea 19-21 en `initState()`)
   - Tiene lógica de negocio en initState. El widget tiene que saber cuándo fetchear datos. Eso debería ir en una clase separada.

3. **Mantener el estado de la lista de incidentes** (línea 13: `List<dynamic> incidentes = []`)
   - Gestiona la lista completa. Si después queremos paginar o cache, esto se vuelve complicado.

4. **Mantener estado de carga y errores** (líneas 14-15: `bool cargando = false;` y `String error = '';`)
   - Necesario, pero podría abstraerse en un estado más estructurado.

5. **Filtrar datos** (línea 28-30 en `incidentesFiltrados`)
   - Lógica de negocio. Si los filtros se complejizarían, esto debería ser un servicio aparte.

6. **Construir toda la UI** (el método `build()` con todo lo que está dentro: barras, chips, cards, etc.)
   - Esto es lo que sí debería hacer, pero comparte espacio con todo lo demás.

7. **Manejar navegación** (línea 95 en `onTap: () => Navigator.pushNamed(context, '/detail', arguments: incidente)`)
   - El widget dispara navegación. Esto mezcla lógica de UI con lógica de flujo de app.

**Separación propuesta:**
- Responsabilidades 1 y 2: Servicio de API
- Responsabilidades 3, 4, 5: Controlador de negocio o ViewModel
- Responsabilidad 6: Aquí debería quedarse en HomeScreen
- Responsabilidad 7: Podría estar aquí o en un router centralizado

### 2b) El problema de tener Dio dentro del widget

Hay **dos instancias separadas de Dio** en la app:
- Una en `home_screen.dart` línea 10: `final Dio _dio = Dio();`
- Otra en `detail_screen.dart` línea 10: `final Dio _dio = Dio();`

El problema concreto que genera esto:

1. **Inconsistencia de configuración**: Si necesito agregar un interceptor de autenticación (por ejemplo, agregar un token en cada request), tendría que hacerlo en dos lugares. Si lo hago en uno y me olvido en otro, algunos requests tendrán autenticación y otros no.

2. **Cambios de API difíciles de mantener**: Si mañana la URL base cambia de `https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io` a `https://loja.gov.ec/api`, tengo que buscar y reemplazar en cada pantalla donde se configuró Dio. Fácil de olvidar.

3. **Timeouts inconsistentes**: Si decido que los timeouts deben ser 30 segundos en lugar de los default, nuevamente tengo que hacerlo en dos sitios.

4. **Manejo de errores inconsistente**: En `home_screen.dart` hay manejo de `DioException` (línea 41 en `cargarIncidentes()`), pero en `detail_screen.dart` no hay nada. Si el usuario intenta marcar algo como favorito y falla la conexión (suponiendo que el botón hace un request), la app se caería.

5. **Testing complicado**: Si quiero hacer tests unitarios, tendría que mockear Dio en dos lugares diferentes. Con una única instancia sería más fácil.

La solución obvia es crear **una única instancia de Dio**, compartida por toda la app, que todas las pantallas usen.

### 2c) Lo que no debería estar en build()

En `home_screen.dart`, dentro de `build()` está esta línea (línea 49):

```dart
contadorRebuild++;
```

Eso es un problema serio. La variable `contadorRebuild` (línea 17) está inicializada en 0, y cada vez que el widget se reconstruye, ese contador sube.

¿Por qué es un problema? Porque `build()` se ejecuta **decenas de veces** durante la interacción normal:
- Cuando el usuario toca un filtro: rebuild para mostrar que está seleccionado
- Cuando el usuario scrollea la lista: rebuilds por rendimiento
- Cuando se anima algo: varios rebuilds por frame
- Incluso sin que el usuario haga nada, si otro widget en el árbol se reconstruye y afecta el layout

Si dejas un contador ahí, después de 10 minutos de uso normal, ese contador podría estar en 500, 1000 o más. Si alguien intenta debuguear basándose en ese número, va a pensar que algo está horriblemente mal y que el widget se reconstruye constantemente, cuando en realidad es completamente normal.

Además, esto **puede ser intencional pero accidental** — parece que alguien lo dejó ahí para debuguear y olvidó removerlo.

**Cómo corregirlo:**
- Si está ahí solo para debugging, eliminarlo completamente.
- Si existe una razón real para contar rebuilds, eso debería hacerse en un DevTools Profiler o en logs específicos que se activen solo en modo debug, no en el código de producción.

### 2d) Diseña la solución: cómo reorganizarías el código

Si consideramos todo lo anterior (2a, 2b, 2c), acá está cómo reestructuraría la app:

**1. Clase `ApiService` (o `IncidentesService`)**
- Vive en su propio archivo: `lib/services/api_service.dart`
- Responsabilidades:
  - Configurar y mantener la única instancia de Dio
  - Definir URL base, timeouts, interceptores
  - Métodos para cada endpoint: `getIncidentes()`, `getIncidenteById(id)`, `marcarFavorito(id)`, etc.
- El método `getIncidentes()` devolvería una `Future<List<Incident>>`
- Los errores ya estarían manejados acá

**2. Clase `IncidentesRepository` (o `IncidentsRepository`)**
- Vive en `lib/repositories/incidentes_repository.dart`
- Responsabilidades:
  - Coordinar entre API y caché local
  - Manejar lógica de persistencia (si hay favoritos guardados, por ejemplo)
  - Aplicar filtros sobre los datos
- Métodos: `getIncidentes()`, `filtrarPor(tipo)`, `guardarFavorito(id)`, etc.
- Esto permite que la lógica de negocio sea independiente del widget

**3. Modelo de datos `Incident`**
- Vive en `lib/models/incident.dart`
- En lugar de pasar `Map<String, dynamic>` por todas partes, tenemos una clase fuertemente tipada
- Tiene propiedades: `id`, `title`, `type`, `zone`, `status`, `description`, `isFavorite`
- Métodos helper: `get isResolved => status == 'resolved'`
- Esto elimina el riesgo de acceder a claves que no existen

**4. `HomeScreen` simplificado**
- `_HomeScreenState` solo hace:
  - En `initState()`: llamar a `repository.getIncidentes()`
  - En `build()`: mostrar UI basada en el estado (cargando, error, datos)
  - Manejo del filtro: `setState(() => filtroActual = nuevoFiltro)` y luego redraw
- Eliminar `contadorRebuild`, eliminar Dio, eliminar toda la lógica de fetch
- El `onTap` en cada tarjeta continúa navegando a `/detail` con el incidente como argumento

**5. `DetailScreen` como StatelessWidget**
- Como se propuso en 1c
- Solo recibe el incidente y lo muestra

**6. Inyección de dependencias**
- En `main.dart`, instanciar el `ApiService` una sola vez
- Pasar el `Repository` a `HomeScreen` via constructor o `InheritedWidget`
- Alternativa más limpia: usar un patrón como `Provider` o `GetIt`

**Flujo de datos resultante:**
```
HomeScreen -> Repository -> ApiService -> API
                      ↓
                   Datos
                      ↓
              StateBuilding (UI)
```

En lugar del flujo actual:
```
HomeScreen hace TODO (Dio, API, filtrado, UI, etc.)
```

**Ventajas:**
- Cambiar la API es un cambio en un archivo
- Testing es simple: mockeamos el Repository
- Reutilizable: otro widget podría usar el mismo Repository
- Mantenible: cada clase tiene una única razón para cambiar

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

En `home_screen.dart`, línea 95:
```dart
Navigator.pushNamed(context, '/detail', arguments: incidente);
```

Se pasa `incidente` directamente. ¿Qué es `incidente`? Es un elemento de la lista `incidentesFiltrados`, que viene de la respuesta JSON del API. Así que es un `dynamic`, pero en realidad es un `Map<String, dynamic>`.

En `detail_screen.dart`, línea 15-16, se recibe así:
```dart
final incidente =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
```

**El riesgo concreto:**

Si en algún momento el API cambia su estructura y devuelve:
```json
{
  "id": 1,
  "title": "Bache en la calle 10",
  "incidentType": "pothole",  // Era "type"
  "zone": "Centro",
  "status": "resolved",
  "description": "..."
}
```

Entonces en `detail_screen.dart`, cuando se ejecute la línea 37:
```dart
_buildEtiquetaTipo(incidente['type'] ?? '', colorEstado),
```

Se va a obtener `null` (porque la key ahora es `incidentType`), y se mostraría "Flooding" por default (el último case de la función). El usuario vería incorrecto el tipo de incidente.

O si el API deja de devolver el campo `status`, entonces en la línea 17:
```dart
final esResuelto = incidente['status'] == 'resolved';
```

`esResuelto` sería `false` porque `null == 'resolved'` es false. Todo el color y la lógica estaría mal.

**El riesgo en tiempo de ejecución es:** Si el backend cambia aunque sea levemente, la app no crasheará, pero **mostrará datos incorrectos sin avisar**. No habría un error claro, solo incidentes mostrándose con información equivocada.

### 3b) El botón que hace algo cuestionable

En `detail_screen.dart`, línea 65-71:
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () => Navigator.pushNamed(context, '/'),
    icon: const Icon(Icons.arrow_back),
    label: const Text('Back to home'),
  ),
),
```

El botón dice "Back to home" y usa `Navigator.pushNamed(context, '/')`. Eso es **cuestionable**.

¿Qué hace `pushNamed`? Agrega una nueva pantalla a la pila de navegación. Así que cuando el usuario presiona este botón, hace esto:
1. La pila de navegación es: `[HomeScreen, DetailScreen]`
2. Se ejecuta `pushNamed('/')`, que **añade otra instancia de HomeScreen**
3. La pila ahora es: `[HomeScreen (vieja), DetailScreen, HomeScreen (nueva)]`

Si el usuario presiona el botón varias veces seguidas (o lo presiona una sola vez), la pila crece. Después, si presiona el botón de atrás del dispositivo (que hace `pop()`), tendría que presionarlo varias veces para salir de la app, dependiendo de cuántas instancias de HomeScreen creó.

Peor aún, si el usuario tiene scroll position guardado en la primera HomeScreen, la segunda instancia nueva tendrá scroll en la posición default. El estado de la anterior se perdió.

**Lo correcto sería:**
- Usar `Navigator.pop(context)` en lugar de `pushNamed`
- O si se quiere ir específicamente a home y descartar todo lo anterior, usar `Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false)`

### 3c) ¿Cómo mejorarías el paso de datos?

Crearían un **modelo de datos fuertemente tipado** en `lib/models/incident.dart`:

```dart
class Incident {
  final int id;
  final String title;
  final String type;  // 'pothole', 'lighting', 'flooding'
  final String zone;
  final String status;  // 'resolved', 'pending', etc.
  final String description;
  
  Incident({
    required this.id,
    required this.title,
    required this.type,
    required this.zone,
    required this.status,
    required this.description,
  });
  
  // Constructor desde JSON
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'unknown',
      zone: json['zone'] ?? '',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
    );
  }
  
  // Getters helper
  bool get isResolved => status == 'resolved';
  String get displayType => type == 'pothole' ? 'Pothole' 
      : type == 'lighting' ? 'Lighting' : 'Flooding';
}
```

Luego, en `home_screen.dart`:
- En lugar de `List<dynamic> incidentes = []`, sería `List<Incident> incidentes = []`
- Cuando el API devuelve datos, hacer: `incidentes = response.data.map((json) => Incident.fromJson(json)).toList()`
- Cuando se navega: `Navigator.pushNamed(context, '/detail', arguments: incidente)` (pasa un `Incident`, no un `Map`)

En `detail_screen.dart`:
- En lugar de `as Map<String, dynamic>`, sería `as Incident`
- Acceso tipado: `incidente.title`, `incidente.isResolved` (no `incidente['title']` ni comprobaciones de null manuales)
- Si el API cambia, la clase `Incident.fromJson()` capturaría eso en un lugar central

**Ventajas:**
- El compilador te avisa si accedes a una propiedad que no existe
- Si el API falta un campo, `Incident.fromJson()` lo maneja con defaults
- Refactoring es más fácil: cambiar el nombre de `type` a `incidentType` requiere cambiar un lugar
- IDEs te hacen autocomplete en lugar de tener que recordar los nombres de las keys

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Existen **dos instancias de Dio** en la app:

1. En `home_screen.dart`, línea 10:
   ```dart
   final Dio _dio = Dio();
   ```

2. En `detail_screen.dart`, línea 10:
   ```dart
   final Dio _dio = Dio();
   ```

**Problemas concretos:**

1. **Configuración duplicada**: Si quiero agregar un interceptor (por ejemplo, uno que agregue un header de autenticación a cada request), tengo que escribir el mismo código dos veces. Fácil de olvidar en uno de los dos.

2. **Cambios de URL base dispersos**: La URL del API está hardcodeada en `home_screen.dart` línea 34:
   ```dart
   final response = await _dio.get(
     'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/incidents',
   );
   ```
   Si mañana cambio a `https://api.loja.gov.ec/incidents`, tengo que buscarlo en dos archivos. Si en el futuro hay tres pantallas que hagan requests, será en tres lugares.

3. **Timeouts inconsistentes**: Si decido que 30 segundos es mucho y quiero bajar a 15 segundos, tengo que configurarlo en ambas instancias.

4. **Caching deshabilitado**: Con dos instancias, cada una tendría su propio cache interno. Si hago un request en HomeScreen y luego en DetailScreen hago el mismo request, Dio no sabría que ya lo hizo, podría hacer el request nuevamente.

5. **Cookies y sesiones fragmentadas**: Si el API requiere mantener sesión, cada Dio tendría su propia cookie jar. Cosas de seguridad se fragmentarían.

**La mejor práctica:** Una única instancia compartida, inicializada en `main.dart` o en un servicio singleton.

### 4b) ¿Qué le falta a la configuración actual de Dio?

En `home_screen.dart` y `detail_screen.dart`, Dio está configurado así:
```dart
final Dio _dio = Dio();
```

Eso es Dio con configuración **completamente default**. En un proyecto real, le falta mucho:

1. **URL base (BaseOptions)**
   - Actualmente, la URL completa está hardcodeada en cada request:
     ```dart
     final response = await _dio.get(
       'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/incidents',
     );
     ```
   - Debería estar en Dio options:
     ```dart
     Dio(BaseOptions(
       baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1',
     ))
     ```
   - Entonces el request sería simplemente: `_dio.get('/incidents')`

2. **Timeouts**
   - Sin configurar, Dio usa defaults. En conexiones lentas (mobile 3G), un request puede tardar 30+ segundos sin avisar nada.
   - Debería tener:
     ```dart
     connectTimeout: Duration(seconds: 15),
     receiveTimeout: Duration(seconds: 20),
     ```
   - Así, si el servidor no responde, la app lo sabe rápido.

3. **Headers comunes**
   - Si el API requiere un `User-Agent` o un `Content-Type: application/json`, eso se debería configurar una sola vez:
     ```dart
     headers: {
       'Content-Type': 'application/json',
     }
     ```

4. **Interceptores**
   - Para logging, autenticación, manejo de errores centralizado:
     ```dart
     _dio.interceptors.add(LoggingInterceptor());
     _dio.interceptors.add(AuthInterceptor());
     ```
   - Actualmente no hay ninguno.

5. **Manejo consistente de errores**
   - Hay un `try-catch` que atrapa `DioException` en `home_screen.dart`, pero no hay en `detail_screen.dart`.
   - Un interceptor podría centralizar esto.

En resumen: la configuración actual es **frágil y no escalable**. Funciona para un mockup, pero en producción generaría problemas.

### 4c) Diseña cómo centralizarías Dio para toda la app

Crearía un archivo `lib/services/api_service.dart` que mantenga una única instancia de Dio configurada:

```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  late final Dio _dio;
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1',
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Agregar interceptor para logging
    _dio.interceptors.add(LoggingInterceptor());
  }
  
  Future<List<dynamic>> getIncidentes() async {
    try {
      final response = await _dio.get('/incidents');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error fetching incidents: ${e.message}');
    }
  }
  
  // Más métodos según sea necesario
  Future<void> markFavorite(int id) async {
    // ...
  }
}
```

**Cómo se usaría en las pantallas:**

En `home_screen.dart`:
```dart
class _HomeScreenState extends State<HomeScreen> {
  final apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }
  
  Future<void> _loadIncidents() async {
    try {
      final incidents = await apiService.getIncidentes();
      setState(() => this.incidents = incidents);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }
}
```

En `detail_screen.dart`:
- No necesita Dio en absoluto si solo muestra datos

**Por qué esto funciona:**

1. **Patrón Singleton**: `ApiService._instance` garantiza que solo exista una instancia
2. **Configuración centralizada**: Todo en un lugar
3. **Reutilizable**: Cualquier pantalla, servicio o clase puede hacer `ApiService().getIncidentes()`
4. **Testeable**: En tests, puedes reemplazar `ApiService` con un mock
5. **Mantenible**: Si necesitas cambiar la URL base, lo haces una sola vez
6. **Escalable**: Si después necesitas agregar autenticación, solo cambias ApiService

Alternativa moderna: usar `GetIt` (paquete de inyección de dependencias) en `main.dart`:
```dart
void main() {
  getIt.registerSingleton(ApiService());
  runApp(MyApp());
}
```

Luego accedes con: `getIt<ApiService>().getIncidentes()`

---

## Resumen de cambios que implementarás el jueves

En orden de prioridad:

1. **Crear el modelo `Incident` (lib/models/incident.dart)**
   - Define la clase con campos tipados
   - Constructor `fromJson()` para parsear la respuesta del API
   - Métodos helper como `isResolved` y `displayType`
   - **Por qué primero:** Afecta cómo se pasa datos entre pantallas. Mejor hacerlo de base.

2. **Crear `ApiService` singleton (lib/services/api_service.dart)**
   - Configurar Dio una sola vez: baseUrl, timeouts, headers
   - Método `getIncidentes()` que retorna `Future<List<Incident>>`
   - Manejo centralizado de errores
   - **Por qué segundo:** Necesario para refactorizar HomeScreen correctamente.

3. **Refactorizar `HomeScreen` (lib/screens/home_screen.dart)**
   - Eliminar la instancia de Dio local
   - Usar `ApiService().getIncidentes()` en lugar de hacer el request directo
   - Eliminar `contadorRebuild`
   - Cambiar `List<dynamic> incidentes` a `List<Incident> incidentes`
   - **Impacto:** La pantalla se simplifica y desaparece la lógica de Dio duplicada.

4. **Convertir `DetailScreen` a `StatelessWidget` (lib/screens/detail_screen.dart)**
   - Eliminar `_DetailScreenState`
   - Eliminar la instancia de Dio
   - Recibir `Incident` en lugar de `Map<String, dynamic>`
   - Eliminar el estado `favorito` (por ahora)
   - Cambiar `Navigator.pushNamed('/')` a `Navigator.pop(context)` en el botón Back
   - **Impacto:** Pantalla más simple, sin estado innecesario, navegación correcta.

5. **Actualizar navegación (lib/main.dart si es necesario)**
   - Verificar que la ruta `/detail` funciona con `Incident` como argumento
   - **Impacto:** Mínimo, probablemente no se necesita cambiar nada acá.
