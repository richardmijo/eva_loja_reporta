# Análisis de código — LojaReport

**Nombre:** José Andrés Quizhpe León  
**Branch:** analisis/Jose-Quizhpe  
**Fecha:** 1/06/2026  
**Repositorio base:** https://github.com/richardmijo/eva_loja_reporta.git

---

## Pregunta 1 — StatelessWidget vs StatefulWidget

### 1a) ¿DetailScreen necesita ser StatefulWidget?

En mi opinión, no. O al menos no por lo que hace la pantalla en general.

Cuando abrí `detail_screen.dart` vi que casi todo sale de los argumentos de navegación. En `build()`, líneas 16 a 20, lo que hace el código es esto:

```dart
final incidente = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
final esResuelto = incidente['status'] == 'resolved';
```

A partir de ahí solo arma la UI con `_buildFila`, `_buildEtiquetaTipo` y unos `Text`. Y en si nada de eso cambia variables internas del widget.

Lo único que sí muta es `bool favorito = false` que se encuentra en la línea 12. Eso se cambia con `setState` en el botón del AppBar en la línea 31, para alternar el icono del bookmark. O sea, técnicamente hay estado, pero es solo eso: un booleano para un icono.

También noté que en la línea 10 hay un `final Dio _dio = Dio()` que en ningún método se usa. Para mí eso confirma que la pantalla no necesita tanta estructura. Su trabajo de verdad es mostrar datos que ya vienen de afuera.

Entonces: `StatefulWidget` solo se justifica por `favorito`, no por mostrar el detalle del incidente.

### 1b) El estado problemático

El que está mal diseñado es `bool favorito = false` en `_DetailScreenState` (`detail_screen.dart`, línea 12).

Lo probé mentalmente con el flujo de la app: el usuario entra a un incidente y `favorito` arranca en `false`. Si toca el bookmark, corre `setState(() => favorito = !favorito)` (línea 31) y el icono cambia. Hasta ahí bien.

Pero si vuelve atrás — con el botón del teléfono o un `Navigator.pop` — Flutter destruye el State y se pierde ese valor. Y si vuelve a abrir el mismo incidente, en `home_screen.dart` línea 199 otra vez se ejecuta `Navigator.pushNamed(context, '/detail', arguments: incidente)`, se crea otra instancia nueva y `favorito` vuelve a `false`.

`HomeScreen` no sabe nada de esto. Solo manda el `Map` del incidente y ya. No guarda si estaba en favoritos ni muestra nada en la lista.

### 1c) ¿Qué cambiarías y por qué?

- Pasaría `DetailScreen` a `StatelessWidget` y le mandaría el incidente por constructor, algo como `DetailScreen({required Incident incidente})`, en lugar de sacarlo con cast dentro de `build()`. Así la pantalla solo pinta lo que recibe.

- Sacaría `favorito` de ahí. Si tiene que persistir, lo pondría en un Provider con un `Set` de IDs. Si no, con `Navigator.pop(context, favorito)` al menos Home podría recibir el valor cuando el usuario sale.

- Eliminaría el `Dio` de la línea 10 de Detail porque no se usa.

- Cambiaría el botón "Back to home" (línea 69): ahora hace `Navigator.pushNamed(context, '/')` y debería ser `Navigator.pop(context)`.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

`_HomeScreenState` en `home_screen.dart` hace de todo. Esto es lo que encontré:

- **Red:** tiene `Dio _dio` (línea 10) y en `cargarIncidentes()` (líneas 25-48) hace el GET a la API. Eso no debería estar en un widget, sino en un repositorio.

- **Estado:** maneja `incidentes`, `cargando` y `error` (líneas 12-14). Podría quedarse parte en la UI, pero lo ideal es un Provider o ViewModel.

- **Filtrado:** `filtro` y el getter `incidentesFiltrados` (líneas 15 y 50-53). La regla de filtro podría vivir fuera del widget.

- **UI:** `build()`, `_buildBarraFiltros()`, `_buildContenido()`, `_buildChipFiltro()`. Esto sí le corresponde.

- **Tarjetas:** `_buildTarjetaIncidente()` (líneas 157-203) con iconos y colores según type/status. Podría ser un widget aparte.

- **Navegación:** va a `/about` (línea 65) y a `/detail` (línea 199). Está bien que navegue, pero debería pasar datos tipados.

- **Side effect raro:** `contadorRebuild++` en la línea 57, dentro de `build()`. Eso no va ahí.

- **Recargar:** el FAB (línea 71) y el botón Retry (línea 134) llaman `cargarIncidentes`. Como acción de UI está bien, pero el método no debería tener el HTTP adentro.

En resumen, el widget debería quedarse con la interfaz y los eventos del usuario. Lo demás hay que sacarlo.

### 2b) El problema de tener Dio dentro del widget

Hay dos instancias:

- `home_screen.dart` línea 10: sí se usa en `cargarIncidentes()`.
- `detail_screen.dart` línea 10: declarada pero no se usa en ningún lado.

El problema es que no hay un solo lugar para configurar la red. Si cambia la URL base, hay que buscar en cada `.get()` o en cada `Dio()` nuevo. Lo mismo si quieren poner un token JWT, logs o headers: habría que repetirlo en cada pantalla. Y si agregan otra vista con red, lo más probable es que copien el mismo patrón.

### 2c) Lo que no debería estar en build()

En `home_screen.dart`, línea 57:

```dart
contadorRebuild++;
```

Eso está al inicio de `build()`. El problema es que Flutter puede llamar a `build()` muchas veces: al cambiar el filtro, cuando termina la carga, si rota la pantalla, etc. No es lo mismo que "el usuario entró una vez a la pantalla".

Si ese contador fuera para métricas o debug, los números saldrían inflados. `build()` debería solo retornar widgets, no modificar variables.

Lo quitaría, o si de verdad hace falta contar algo, lo haría en `initState()` o cuando el usuario toque un botón.

### 2d) Diseña la solución: cómo reorganizarías el código

Lo organizaría más o menos así:

- `lib/core/network/dio_client.dart` — un solo Dio con baseUrl, timeouts y LogInterceptor.
- `lib/models/incident.dart` — clase tipada con `fromJson`.
- `lib/repositories/incident_repository.dart` — el GET a `/incidents`, devuelve `List<Incident>`.
- `lib/providers/home_provider.dart` — guarda la lista, cargando, error y filtro. Tiene `loadIncidents()` y `setFiltro()`.
- `lib/screens/home_screen.dart` — solo UI, escucha el provider con `context.watch`.
- `lib/screens/detail_screen.dart` — StatelessWidget que recibe un `Incident`.
- `lib/widgets/incident_card.dart` y `filter_bar.dart` — sacaría la tarjeta y los chips del home para que no quede tan largo.

Cómo se conectaría: en `main()` registro el provider con el repository adentro. El repository usa `DioClient`. Home llama `loadIncidents()` y muestra loading, error o lista. Cuando el usuario toca una tarjeta, navego pasando un `Incident` ya convertido. Detail solo lo muestra. Las pantallas no crean `Dio()` directamente.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Se pasa un `Map<String, dynamic>`. El `incidente` es `dynamic` porque viene directo del JSON de la API.

En `home_screen.dart`, método `_buildTarjetaIncidente()`, línea 199:

```dart
Navigator.pushNamed(context, '/detail', arguments: incidente);
```

Y en `detail_screen.dart`, `build()`, líneas 16-17:

```dart
final incidente = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
```

Dos riesgos que vi:

Primero, un `CastError` si alguien abre `/detail` sin mandar argumentos. `arguments` sería null y el cast falla.

Segundo, un bug silencioso. Si la API un día manda `'state'` en vez de `'status'`, en la línea 19 la comparación `incidente['status'] == 'resolved'` siempre da false. Los resueltos se verían naranja en lugar de verde. En la línea 52 el texto del status quedaría vacío por el `?? ''`. La app no truena, pero muestra mal los datos, y eso cuesta más de encontrar.

También el `!` de `ModalRoute.of(context)!` puede fallar si el contexto no tiene ruta.

### 3b) El botón que hace algo cuestionable

En `detail_screen.dart`, línea 69, el botón "Back to home":

```dart
onPressed: () => Navigator.pushNamed(context, '/'),
```

En vez de cerrar Detail, mete otra `HomeScreen` encima. Si el usuario lo aprieta varias veces el stack queda tipo `Home → Detail → Home → Home → Home`.

Cada Home nuevo corre `initState()` otra vez y vuelve a llamar `cargarIncidentes()`, o sea requests duplicados. Y el botón atrás del teléfono ya no saca de la app de una; hay que pasar por pantallas que quedaron abiertas.

Debería ser `Navigator.pop(context)`.

### 3c) ¿Cómo mejorarías el paso de datos?

Haría una clase `Incident` con los campos tipados:

```dart
class Incident {
  final String id;
  final String title;
  final String type;
  final String zone;
  final String status;
  final String description;

  Incident({
    required this.id,
    required this.title,
    required this.type,
    required this.zone,
    required this.status,
    required this.description,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      zone: json['zone'] ?? '',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
    );
  }
}
```

En Home convertiría antes de navegar: `arguments: Incident.fromJson(incidente)`. En la ruta `/detail` verificaría que el argumento sea `Incident`. Y Detail lo recibiría por constructor, sin cast en cada `build()`.

Así puedo escribir `incidente.status` y si me equivoco en el nombre del campo, Dart me avisa al compilar. El mapeo del JSON queda en un solo sitio.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Dos. Una en `home_screen.dart` línea 10 (sí se usa) y otra en `detail_screen.dart` línea 10 (no se usa).

Sin centralizar, cualquier cambio de URL, token o logs hay que repetirlo. Y en Detail hay un Dio copiado que ni sirve.

### 4b) ¿Qué le falta a la configuración actual de Dio?

En `home_screen.dart` el Dio se crea vacío (línea 10) y la URL completa va en el get (líneas 32-34):

```dart
final response = await _dio.get(
  'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/incidents',
);
```

Le faltan tres cosas importantes:

1. Una `baseUrl` en `BaseOptions` para poder hacer `_dio.get('/incidents')` y cambiar de entorno en un solo lugar.

2. `connectTimeout` y `receiveTimeout`. Sin eso, con mala señal el spinner se puede quedar girando mucho rato. Yo pondría unos 10-15 segundos.

3. Mejor manejo de errores: un `LogInterceptor` en desarrollo, headers como `Content-Type: application/json`, y arreglar un bug que vi: si la API responde 404 o 500, no entra al `if (statusCode == 200)` ni al `catch`, y `cargando` se queda en `true` para siempre (líneas 36-47).

### 4c) Diseña cómo centralizarías Dio para toda la app

Crearía `lib/core/network/dio_client.dart` con una clase `DioClient` que tenga el Dio configurado con `BaseOptions` (baseUrl, timeouts, headers) y los interceptores, incluido el log.

Las pantallas no crearían `Dio()`. Solo el `IncidentRepository` usaría ese cliente para hacer `get('/incidents')`. En `main.dart` lo instancio una vez y lo paso al repository con Provider.

Si después hay que meter un token JWT, lo agrego en un interceptor de ese archivo y aplica para toda la app.

---

## Resumen de cambios que implementarás el jueves

1. Centralizar Dio en `dio_client.dart` y quitar las instancias de las pantallas.
2. Crear el modelo `Incident` y el `IncidentRepository` para sacar el HTTP de `cargarIncidentes()`.
3. Mover el estado de Home a un `HomeProvider` (lista, cargando, error, filtro).
4. Pasar `Incident` tipado entre pantallas y cambiar el botón de Detail a `Navigator.pop(context)`.
5. Convertir DetailScreen a StatelessWidget con el incidente por constructor.
6. Quitar `contadorRebuild++` y arreglar el bug de `cargando` cuando el status no es 200.
7. Sacar `IncidentCard` y `FilterBar` a widgets aparte para achicar `home_screen.dart`.
