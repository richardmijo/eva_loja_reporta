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

No. La pantalla solo recibe datos por argumentos y los muestra. Lo único que cambia es `favorito` (línea 11), pero ese estado no se guarda en nada, así que se pierde cuando navegas atrás. Debería ser StatelessWidget.

### 1b) El estado problemático

La variable `bool favorito` (línea 11) cuando el usuario marca un incidente como favorito, pero cuando presiona "Back to home" (línea 65 con `Navigator.pushNamed`) y vuelve, se crea una nueva instancia del widget y `favorito` vuelve a `false`. El cambio desaparece. HomeScreen ni siquiera sabe que pasó.

### 1c) ¿Qué cambiarías y por qué?

1. Cambiar a StatelessWidget
2. Eliminar la variable `favorito` (línea 11)
3. Eliminar Dio que no se usa (línea 10)
4. Si favoritos se implementan, que sea desde HomeScreen con persistencia real

Así DetailScreen solo muestra datos, nada más.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

- Configurar Dio y hacer requests (línea 10, 34) → debería ser un servicio
- Cargar datos iniciales en initState (línea 19) → lógica de negocio
- Mantener la lista de incidentes (línea 13)
- Mantener estado de carga y errores (líneas 14-15)
- Filtrar incidentes (línea 28-30) → lógica de negocio
- Construir toda la UI
- Manejar navegación (línea 95)

Hace demasiado. La UI debería estar acá, pero todo lo demás no.

### 2b) El problema de tener Dio dentro del widget

Hay dos instancias de Dio: una en `home_screen.dart` (línea 10) y otra en `detail_screen.dart` (línea 10).

Problemas:
- Si cambio la URL base del API, tengo que hacerlo en dos lugares
- Timeouts configurados diferente en cada pantalla
- Si agrego un interceptor, tengo que hacerlo dos veces
- Si el API cambia, cambios inconsistentes
- Testing complejo: hay que mockear Dio en múltiples lugares

Una sola instancia compartida resuelve todo.

### 2c) Lo que no debería estar en build()

Línea 49 en `home_screen.dart`: `contadorRebuild++;`

Eso no debería estar ahí. El método `build()` se ejecuta decenas de veces por cada interacción: cuando filtras, scrolleas, animas algo. Si dejas un contador, después de 10 minutos está en 500+ sin que nada esté roto. Es código de debug olvidado.

### 2d) Diseña la solución: cómo reorganizarías el código

Crearía 3 cosas:

1. **Clase `Incident` (lib/models/incident.dart)**
   - Modelo fuertemente tipado en lugar de `Map<String, dynamic>`
   - Constructor `fromJson()` para parsear el API
   - Getters: `isResolved`, `displayType`

2. **Clase `ApiService` (lib/services/api_service.dart)**
   - Singleton con la única instancia de Dio
   - Configuración centralizada: baseUrl, timeouts, headers
   - Método `getIncidentes()` que devuelve `Future<List<Incident>>`

3. **Simplificar `HomeScreen`**
   - Eliminar Dio local
   - Usar `ApiService().getIncidentes()` en initState
   - Cambiar `List<dynamic> incidentes` a `List<Incident> incidentes`
   - La UI se queda igual

Así cada clase tiene una responsabilidad clara: Models → Data, Services → API, Screens → UI.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

En `home_screen.dart` línea 95 se pasa `incidente` (un `Map<String, dynamic>`).

En `detail_screen.dart` línea 15-16 se recibe así:
```dart
final incidente = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
```

El riesgo: si el API cambia y devuelve `incidentType` en lugar de `type`, entonces en línea 37 cuando accedes a `incidente['type']`, obtienes `null`. La app no crasheará pero mostrará datos incorrectos sin avisar.

### 3b) El botón que hace algo cuestionable

En `detail_screen.dart` línea 65-71, el botón "Back to home" hace `Navigator.pushNamed(context, '/')`.

Eso es un `push`, no un `pop`. Significa que agrega una **nueva** pantalla a la pila en lugar de ir atrás. Así que si presionas ese botón y luego el botón atrás del teléfono, tienes que presionar dos veces. Cada vez que presionas el botón, la pila crece.

Lo correcto es usar `Navigator.pop(context)` o `Navigator.pushNamedAndRemoveUntil`.

### 3c) ¿Cómo mejorarías el paso de datos?

Crearía una clase `Incident` (como menciono en 2d) con propiedades tipadas:
```dart
class Incident {
  final int id;
  final String title;
  final String type;
  final String zone;
  final String status;
  final String description;
  
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(...);
  }
}
```

En `home_screen.dart`: `List<Incident> incidentes` en lugar de `List<dynamic>`
En `detail_screen.dart`: recibe `as Incident` en lugar de `as Map`

Así, si el API cambia, Dart te avisa si accedes a una propiedad que no existe.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Dos: una en `home_screen.dart` (línea 10) y otra en `detail_screen.dart` (línea 10).

Problemas:
- Si cambio URL base, cambio en dos lugares
- Configuración de timeouts duplicada
- Interceptores deben agregarse dos veces
- Manejo de errores inconsistente
- Difícil de testear

Una sola instancia centralizada resuelve todo eso.

### 4b) ¿Qué le falta a la configuración actual de Dio?

Actualmente es: `final Dio _dio = Dio();` (sin configuración)

Le falta:
- **BaseOptions**: URL base centralizada, en lugar de hardcodear la URL completa en cada request
- **Timeouts**: conexión de 15 segundos, respuesta de 20 segundos. Sin eso, requests pueden tardar indefinidamente
- **Headers**: `Content-Type: application/json` u otros headers que requiera el API
- **Interceptores**: para logging, autenticación, manejo consistente de errores

Sin esto funciona con el mockapi, pero en producción genera problemas.

### 4c) Diseña cómo centralizarías Dio para toda la app

Crearía `lib/services/api_service.dart` con un singleton:

```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 20),
    ));
  }
  
  Future<List<dynamic>> getIncidentes() async {
    final response = await _dio.get('/incidents');
    return response.data;
  }
}
```

Luego en `home_screen.dart` simplemente: `ApiService().getIncidentes()`

Ventajas: una sola URL, configuración centralizada, fácil de testear.

---

## Resumen de cambios que implementarás el miércoles

1. **Crear `lib/models/incident.dart`**: Modelo tipado con `fromJson()`
2. **Crear `lib/services/api_service.dart`**: Singleton de Dio centralizado
3. **Refactorizar `HomeScreen`**: Usar ApiService, eliminar Dio local, cambiar a `List<Incident>`
4. **Convertir `DetailScreen` a StatelessWidget**: Eliminar estado, cambiar navegación a `pop()`
5. **Actualizar navegación**: Pasar `Incident` en lugar de `Map`
