# Análisis de código — LojaReport

**Nombre:** James Luis Romero Bravo 
**Branch:** analisis/james-romero  
**Fecha:** 6/1/2026  
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

No está justificado. Revisando `detail_screen.dart` completo, la pantalla no tiene `initState()`, no hace llamadas asíncronas, no maneja animaciones y no muta nada por sí sola. Todo lo que muestra viene del argumento de ruta que llega por `ModalRoute.of(context)!.settings.arguments` — datos que llegan de afuera y no cambian mientras la pantalla está abierta. Un `StatefulWidget` se justifica cuando el widget necesita cambiar su propio estado interno. Aquí eso no pasa para la función principal de la pantalla, así que la elección agrega complejidad sin ningún beneficio.

### 1b) El estado problemático

El único estado real en `_DetailScreenState` es este booleano en la línea 10:

```dart
bool favorito = false;
```

Se usa para alternar el ícono de marcador en el `AppBar`. El problema es que cuando el usuario presiona el favorito y luego navega hacia atrás, Flutter destruye ese `State` por completo. Al volver al mismo incidente, se crea un nuevo `_DetailScreenState` y `favorito` vuelve a ser `false` — la marcación se pierde sin aviso. Además, `HomeScreen` no sabe nada de ese estado: no recibe ningún callback, no hay ningún dato compartido. El favorito existe visualmente pero no tiene ningún efecto real en la app.

### 1c) ¿Qué cambiarías y por qué?

Tres cambios concretos:

1. **Convertir `DetailScreen` en `StatelessWidget`**: cambiar `extends StatefulWidget` por `extends StatelessWidget` y eliminar `createState()` y la clase `_DetailScreenState`. La pantalla solo lee datos, así que puede ser completamente stateless. El método `build()` queda igual — leer de `ModalRoute` funciona igual en un `StatelessWidget`.

2. **Sacar `favorito` de la pantalla**: ese booleano no le pertenece a una pantalla que se destruye al navegar. Lo correcto sería manejarlo en un nivel superior — por ejemplo, en `HomeScreen` como parte del modelo del incidente, o en un estado compartido. Si no hay persistencia real, mejor eliminarlo temporalmente que dejarlo como estado falso.

3. **Eliminar `_DetailScreenState`**: sin estado mutable, esa clase no cumple ningún propósito. Desaparece junto con `createState()`.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

`_HomeScreenState` hace demasiadas cosas a la vez:

- **Instancia y posee un `Dio`** (`final Dio _dio = Dio()`): esto es responsabilidad de un servicio o repositorio, no de un widget.
- **Hace la llamada HTTP** en `cargarIncidentes()`: la lógica de red no debería vivir en la capa de UI.
- **Almacena la lista de incidentes** como `List<dynamic>`: sin tipo, sin modelo, difícil de mantener.
- **Filtra incidentes** en el getter `incidentesFiltrados`: es lógica de negocio, no de construcción de interfaz.
- **Maneja el estado de carga y error** (`cargando`, `error`): esto sí puede estar aquí, aunque en una arquitectura más ordenada iría en un ViewModel.
- **Construye toda la UI** con cuatro métodos privados (`_buildBarraFiltros`, `_buildContenido`, `_buildTarjetaIncidente`, `_buildChipFiltro`): algunos de estos deberían ser widgets propios.
- **Incrementa `contadorRebuild`** dentro de `build()`: código de debug que no debería estar en producción.

### 2b) El problema de tener Dio dentro del widget

`home_screen.dart` línea 8: `final Dio _dio = Dio()`
`detail_screen.dart` línea 8: `final Dio _dio = Dio()`

Dos instancias independientes generan problemas concretos:

- Si la URL base de la API cambia, hay que cambiarla en dos lugares. Si se olvida uno, una pantalla apunta a una API diferente a la otra.
- Si se necesita agregar autenticación con un header `Authorization`, hay que configurarlo en ambas instancias. Si una queda desactualizada, solo esa pantalla empieza a fallar.
- Ninguna de las dos tiene `connectTimeout` ni `receiveTimeout`. Sin eso, Dio puede esperar indefinidamente una respuesta y la app se queda congelada mostrando el indicador de carga para siempre.

### 2c) Lo que no debería estar en build()

En `home_screen.dart`, primera línea dentro de `build()`:

```dart
contadorRebuild++;
```

`build()` en Flutter no se llama una vez — se llama cada vez que el framework necesita redibujar el widget, lo que puede ocurrir decenas de veces durante un scroll, una animación o cualquier `setState()`. Ese contador se incrementa en cada redibujado, así que su valor no mide nada significativo. Si fuera lógica real en lugar de un contador de debug, produciría resultados incorrectos. `build()` debe ser puro: solo construir widgets, sin efectos secundarios. La corrección es simple: eliminar esa línea.

### 2d) Diseña la solución: cómo reorganizarías el código

La idea es separar en tres capas claras:

**`lib/models/incident.dart` — Modelo de datos**
Una clase `Incident` con campos tipados: `id`, `title`, `type`, `zone`, `status`, `description`, todos `String`. Con un constructor `Incident.fromJson(Map<String, dynamic> json)` que convierte la respuesta de la API. Esto elimina todos los `incidente['title'] ?? ''` dispersos en los widgets.

**`lib/services/api_client.dart` — Cliente HTTP centralizado**
Un singleton con una única instancia de Dio configurada con `baseUrl`, `connectTimeout`, `receiveTimeout` y un `LogInterceptor`. Ningún widget crea Dio directamente — todos usan `ApiClient.instance`.

**`lib/repositories/incident_repository.dart` — Repositorio**
Una clase con un solo método: `Future<List<Incident>> fetchIncidents()`. Usa `ApiClient.instance`, llama al endpoint, convierte el JSON en lista de `Incident` y lanza errores tipados si algo falla. Aquí vive `cargarIncidentes()` — fuera del widget.

**`HomeScreen` reducida**
Solo maneja `cargando`, `error` y `filtro` como estado de UI. Llama al repositorio. Construye widgets. Nada más.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

En `home_screen.dart`, dentro de `_buildTarjetaIncidente()`:

```dart
Navigator.pushNamed(context, '/detail', arguments: incidente);
```

`incidente` es de tipo `dynamic` — viene de `List<dynamic>`, que es lo que devuelve Dio sin modelo. En la práctica es un `Map<String, dynamic>`.

En `detail_screen.dart`, dentro de `build()`:

```dart
final incidente =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
```

El riesgo concreto está en el cast forzado `as Map<String, dynamic>`. Si alguien navega a `/detail` sin pasar argumentos — por ejemplo desde un deep link o una ruta agregada después — `settings.arguments` es `null`, el cast lanza una excepción y la app crashea. No es un error de compilación: Dart no puede detectarlo porque el tipo es `dynamic`. Solo explota en ejecución.

### 3b) El botón que hace algo cuestionable

Al final del `body` en `detail_screen.dart`:

```dart
ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(context, '/'),
  icon: const Icon(Icons.arrow_back),
  label: const Text('Back to home'),
),
```

Usa `Navigator.pushNamed(context, '/')` en lugar de `Navigator.pop(context)`. Esto no vuelve a `HomeScreen` — agrega una nueva instancia de `HomeScreen` encima del stack. Si el usuario presiona ese botón tres veces, el stack queda así:

El botón físico de atrás del dispositivo no lleva a donde el usuario espera. Cada `HomeScreen` apilada además hace su propia llamada a la API. La corrección es reemplazar `pushNamed(context, '/')` por `Navigator.pop(context)`.

### 3c) ¿Cómo mejorarías el paso de datos?

Crear el modelo `Incident` en `lib/models/incident.dart`:

Incident {
id          : String
title       : String
type        : String   // 'pothole' | 'lighting' | 'flooding'
zone        : String
status      : String   // 'pending' | 'resolved'
description : String
}

Y recibir ese modelo directamente en el constructor de `DetailScreen`:

```dart
class DetailScreen extends StatelessWidget {
  final Incident incidente;
  const DetailScreen({required this.incidente});
}
```

Esto elimina el cast `as Map<String, dynamic>` por completo. El compilador garantiza en tiempo de compilación que `DetailScreen` siempre recibe un `Incident` válido — si no se pasa, el error aparece antes de correr la app, no en producción. Acceder a `incidente.title` en lugar de `incidente['title']` también hace que un campo renombrado en la API sea un error de compilación, no un crash silencioso.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Existen **dos instancias**:

1. `home_screen.dart`, línea 8: `final Dio _dio = Dio();` dentro de `_HomeScreenState`
2. `detail_screen.dart`, línea 8: `final Dio _dio = Dio();` dentro de `_DetailScreenState`

El problema: son independientes y sin configuración. No comparten timeouts, no comparten interceptores, no comparten URL base. Cualquier cambio en la configuración de red tiene que hacerse dos veces. Y si se agrega una tercera pantalla, tres veces.

### 4b) ¿Qué le falta a la configuración actual de Dio?

La configuración actual es simplemente `Dio()` sin ningún parámetro. Le faltan al menos tres cosas:

1. **`baseUrl`**: la URL completa está hardcodeada directamente en la llamada. Con `BaseOptions(baseUrl: '...')`, las llamadas quedan como `dio.get('/incidents')` y cambiar de entorno es un solo cambio en un solo lugar.

2. **Timeouts**: sin `connectTimeout` ni `receiveTimeout`, si el servidor no responde la app espera para siempre. El usuario ve el indicador de carga indefinidamente sin posibilidad de recuperación.

3. **Interceptor de logging**: no hay ningún `Interceptor` registrado. Un `LogInterceptor` permite ver en consola qué se manda y qué llega. Sin eso, debuggear problemas de red es adivinar.

### 4c) Diseña cómo centralizarías Dio para toda la app

Un archivo `lib/services/api_client.dart` con un singleton:
ApiClient
├── static final ApiClient _instance   ← instancia única
├── final Dio dio                       ← configurado una sola vez
├── factory ApiClient() → _instance    ← siempre devuelve la misma
└── ApiClient._internal()              ← constructor privado con toda la config

En el constructor privado se configura `baseUrl`, `connectTimeout`, `receiveTimeout` y `LogInterceptor`.

Las pantallas no tocan `ApiClient` directamente — lo usa el repositorio:

Si aún no se implementa el repositorio, como mínimo se reemplaza `Dio()` por `ApiClient().dio` en cada pantalla. El resultado: una sola configuración, un solo lugar para cambiar la URL, un solo interceptor para toda la app.

---

## Resumen de cambios que implementarás el miércoles

1. **Corregir el botón "Back to home"** en `detail_screen.dart`: cambiar `Navigator.pushNamed(context, '/')` por `Navigator.pop(context)`. Es una línea, soluciona el stack roto.

2. **Eliminar `contadorRebuild++`** de `build()` en `home_screen.dart`. Es una línea de debug que no debería existir en producción.

3. **Crear `ApiClient` singleton** en `lib/services/api_client.dart` con `baseUrl`, timeouts y `LogInterceptor`. Reemplazar los dos `Dio()` locales con `ApiClient().dio`.

4. **Crear el modelo `Incident`** en `lib/models/incident.dart` con campos tipados y `fromJson`. Reemplazar `List<dynamic>` por `List<Incident>` y los accesos por key string por propiedades tipadas.

5. **Convertir `DetailScreen` en `StatelessWidget`**: eliminar `_DetailScreenState` y `createState()`. Mover o eliminar `favorito` según si hay persistencia real.

6. **Crear `IncidentRepository`** en `lib/repositories/incident_repository.dart` con `fetchIncidents()`. Sacar la lógica de red de `_HomeScreenState`.