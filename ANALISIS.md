# Análisis de código — LojaReport

**Nombre:** Fernando Castillo  
**Branch:** analisis/fernando-castillo  
**Fecha:** 1/6/2026  
**Repositorio base:** https://github.com/richardmijo/eva_loja_reporta.git

---

## Instrucciones

Responde cada pregunta directamente en este archivo usando Markdown.  
Se específico — menciona el archivo y el método del que hablas.  
Una respuesta genérica que podría aplicar a cualquier app Flutter no sirve.  
Cuando termines, haz push de tu branch y publica la URL en Canvas.

---

## Pregunta 1 — StatelessWidget vs StatefulWidget

### 1a) ¿DetailScreen necesita ser StatefulWidget?

**No, no está justificado.**
Si analizamos el archivo [detail_screen.dart](file:///c:/Users/ASUS/Desktop/quinto%20semestre/programacion%20movil/examen/eva_loja_reporta/lib/screens/detail_screen.dart), vemos que el widget únicamente recibe los datos del incidente como argumentos de navegación a través de `ModalRoute.of(context)!.settings.arguments` (línea 16-17) y los renderiza.
El único estado local que tiene es `bool favorito = false;` (línea 12) que se conmuta en el botón del AppBar. Sin embargo, este estado no es persistente ni interactúa de forma real con el resto de la app, por lo que la pantalla en sí misma actúa casi por completo como un presentador estático de datos. La presencia de este único estado local se puede y se debe manejar fuera de la vista para evitar la complejidad y el consumo de recursos de un `StatefulWidget`.

### 1b) El estado problemático

El estado en esta pantalla es la variable `favorito` (línea 12).
**Problemas de diseño:**
1. **Pérdida de estado al navegar hacia atrás:** Debido a que el estado se encuentra dentro de `_DetailScreenState`, cuando el usuario regresa a la pantalla anterior (`HomeScreen`) y vuelve a abrir el detalle del mismo incidente, la pantalla de detalle anterior es eliminada de la pila de navegación (se ejecuta `dispose()`). Al entrar de nuevo, se crea una nueva instancia de la pantalla y su estado se reinicia a `favorito = false`, perdiendo la selección previa del usuario.
2. **Acoplamiento / Aislamiento:** `HomeScreen` no tiene conocimiento alguno de este estado local. Si un incidente es marcado como favorito en `DetailScreen`, no hay manera de que la lista en `HomeScreen` refleje esta propiedad (por ejemplo, mostrando una estrella o un marcador en la tarjeta del incidente).

### 1c) ¿Qué cambiarías y por qué?

Si rediseñara esta pantalla, aplicaría los siguientes cambios precisos:
1. **Convertir `DetailScreen` en un `StatelessWidget`:** Eliminaría la clase `_DetailScreenState` y haría que `DetailScreen` herede directamente de `StatelessWidget`. Todos los métodos de renderizado y el `build` pasarían a la clase principal.
2. **Extraer el estado `favorito` a la capa de negocio:** Quitaría el campo local `bool favorito = false;` de la pantalla. En su lugar, el estado de "favorito" de cada incidente debe formar parte de la entidad de datos (ej. un campo `isFavorite` dentro de una clase modelo `Incident`) y ser gestionado a través de un controlador o manejador de estado centralizado (ej. `IncidentController` o un Provider).
3. **Modificar la acción del botón de favorito:** En la línea 31 de `detail_screen.dart`, cambiaría el `onPressed: () => setState(() => favorito = !favorito)` para que invoque una función del controlador central, por ejemplo: `onPressed: () => incidentController.toggleFavorite(incidente.id)`.
4. **Beneficios del diseño:**
   - **Persistencia en la sesión:** Los incidentes marcados como favoritos no perderán su estado al navegar hacia atrás.
   - **Reactividad global:** La pantalla `HomeScreen` podrá reaccionar y mostrar cuáles incidentes son favoritos en la lista.
   - **Simplicidad y rendimiento:** El widget se vuelve puramente presentacional, reduciendo su huella en memoria y facilitando la escritura de pruebas unitarias.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

En [home_screen.dart](file:///c:/Users/ASUS/Desktop/quinto%20semestre/programacion%20movil/examen/eva_loja_reporta/lib/screens/home_screen.dart), `_HomeScreenState` acumula las siguientes responsabilidades:
1. **Consumo de la API / Red (Líneas 25-48):** Inicializa `Dio` y realiza directamente la petición HTTP `GET` a la API de mockapi. Esto debería estar en una clase de servicio de red o repositorio (`IncidentRepository`).
2. **Gestión de estado local (Líneas 12-17):** Almacena las variables de estado `incidentes`, `cargando`, `error` y `filtro` mediante llamadas a `setState()`. Debería gestionarse en un ViewModel, Controller o State Notifier.
3. **Lógica de negocio y filtrado (Líneas 50-53):** Realiza el filtrado de la lista en memoria mediante la propiedad computada `incidentesFiltrados`. Esto es lógica de negocio y debe ser procesado por el controlador antes de llegar a la UI.
4. **Ruteo y navegación (Líneas 65 y 199):** Ejecuta la navegación a la pantalla de detalles `/detail` y `/about`. (Es aceptable en la vista, pero podría mejorarse usando rutas nombradas tipadas).
5. **Renderizado de la UI (Líneas 56-204):** Construye la estructura visual de la app, incluyendo la barra de filtros, chips y las tarjetas. Debería dividirse en widgets más pequeños.
6. **Métrica/Side effect en build (Línea 57):** Incrementa una variable de depuración (`contadorRebuild++`) directamente dentro del método `build()`, lo cual es una mala práctica de efectos secundarios.

### 2b) El problema de tener Dio dentro del widget

Instanciar `Dio` localmente en cada pantalla (como en la línea 10 de `home_screen.dart` y en la línea 10 de `detail_screen.dart`) genera varios problemas críticos:
1. **Acoplamiento fuerte:** La UI depende directamente de una librería externa (`Dio`). Si decidimos cambiar a `http` o `Chopper` en el futuro, tendremos que modificar todas las pantallas de la aplicación.
2. **Duplicación de código y mantenimiento:** Si necesitamos añadir cabeceras globales (ej. tokens de autorización), cambiar la URL base, configurar interceptores de logs, o definir tiempos de espera (`timeouts`), tendremos que repetir esta configuración en cada pantalla. Si se nos olvida una, la app se comportará de forma inconsistente.
3. **Dificultad para pruebas unitarias:** No es posible mockear las peticiones HTTP fácilmente para testear la UI de forma aislada, ya que la instancia de `Dio` está hardcodeada dentro de las clases de las pantallas.

### 2c) Lo que no debería estar en build()

- En [home_screen.dart:L57](file:///c:/Users/ASUS/Desktop/quinto%20semestre/programacion%20movil/examen/eva_loja_reporta/lib/screens/home_screen.dart#L57) se encuentra la instrucción `contadorRebuild++;`.
- **Por qué es un problema:** El método `build()` en Flutter debe ser una **función pura**, es decir, libre de efectos secundarios y dedicada exclusivamente a describir cómo se debe ver la interfaz en base al estado actual.
  - Modificar variables de estado dentro del `build` sin usar `setState` rompe el ciclo de vida de Flutter y puede producir estados inconsistentes.
  - El método `build` de un widget puede ejecutarse decenas de veces por segundo debido a animaciones, cambios de tamaño del viewport o rebuilds de widgets padres. Por ende, ese contador no mide interacciones reales del usuario, sino decisiones internas del motor de renderizado de Flutter.
- **Cómo corregirlo:** 
  - Si es por depuración, debe eliminarse y utilizar la herramienta oficial *Flutter DevTools* para analizar rebuilds.
  - Si es necesario rastrear cuántas veces cambia de estado o se cargan los datos, esta lógica debe ser movida a las funciones que realmente cambian el estado de la aplicación (como en el método `cargarIncidentes` o al emitir nuevos estados desde un controlador de negocio).

### 2d) Diseña la solución: cómo reorganizarías el código

Para estructurar el proyecto de forma escalable y limpia, implementaría una arquitectura en capas:

1. **Cliente de Red (`DioClient`):**
   - Una clase Singleton que configura una única instancia de `Dio` con la `baseUrl` común, `connectTimeout` y `receiveTimeout` de 5 segundos, y un `LogInterceptor` global para registrar las peticiones.
2. **Modelo de Datos (`Incident`):**
   - Clase inmutable que representa un incidente. Contiene campos fuertemente tipados (`id`, `title`, `description`, `type`, `zone`, `status`, `isFavorite`) y un constructor de fábrica `Incident.fromJson(Map<String, dynamic> json)` para parsear con seguridad los datos de la API.
3. **Capa de Datos (`IncidentRepository`):**
   - Clase encargada de manejar la obtención de datos. Llama al `DioClient`, recibe la respuesta JSON, la mapea a objetos `Incident` y gestiona la persistencia local de favoritos.
   - Métodos: `Future<List<Incident>> fetchIncidents()`, `Future<void> toggleFavorite(String id)`.
4. **Controlador de Negocio (`IncidentController` - usando `ChangeNotifier` o similar):**
   - Maneja el estado de la UI de la pantalla principal y de detalle.
   - Propiedades de estado: `List<Incident> incidents`, `bool isLoading`, `String error`, `String activeFilter`.
   - Métodos: `loadIncidents()` (llama al repositorio), `setFilter(String newFilter)`, `toggleIncidentFavorite(String id)`.
5. **Capa de UI:**
   - Rediseñar `HomeScreen` y `DetailScreen` como widgets más simples (preferiblemente `StatelessWidget` que escuchan al controlador).
   - Separar el código de `home_screen.dart` en sub-widgets: `IncidentFilterChips`, `IncidentCardList` y `IncidentCard`.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

- **Tipo de dato:** Se pasa un `Map<String, dynamic>` (el JSON crudo retornado por MockAPI).
- **Ubicación en el código:**
  - En [home_screen.dart:L199](file:///c:/Users/ASUS/Desktop/quinto%20semestre/programacion%20movil/examen/eva_loja_reporta/lib/screens/home_screen.dart#L199):
    ```dart
    Navigator.pushNamed(context, '/detail', arguments: incidente);
    ```
  - En [detail_screen.dart:L16-17](file:///c:/Users/ASUS/Desktop/quinto%20semestre/programacion%20movil/examen/eva_loja_reporta/lib/screens/detail_screen.dart#L16-17):
    ```dart
    final incidente =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    ```
- **Riesgo concreto en tiempo de ejecución:**
  - Al realizar un cast explícito (`as Map<String, dynamic>`), si por error en el desarrollo se navega a `/detail` sin pasar argumentos, o pasando otro objeto (como el ID del incidente en formato `String`), la aplicación lanzará inmediatamente un error de tipado: `TypeError: type 'Null' (or type 'String') is not a subtype of type 'Map<String, dynamic>' in type cast`, provocando un **crash catastrófico de la pantalla**.
  - Además, al acceder a las propiedades con strings mágicos como `incidente['type']` (línea 40), si cometemos un error de escritura (ej. `incidente['tipe']`), Dart no mostrará ningún error de compilación. Simplemente retornará `null` de forma silenciosa, y si la interfaz no maneja nulos con fallback, fallará visualmente o lanzará excepciones de nulabilidad en cascada.
  - Si la estructura del JSON de la API cambia (por ejemplo, el campo `status` pasa de retornar `resolved` a un entero como `1`), fallarán las comparaciones lógicas de la UI (`incidente['status'] == 'resolved'`) sin previo aviso en tiempo de compilación.

### 3b) El botón que hace algo cuestionable

- **El botón en cuestión:** Se encuentra en [detail_screen.dart:L68-73](file:///c:/Users/ASUS/Desktop/quinto%20semestre/programacion%20movil/examen/eva_loja_reporta/lib/screens/detail_screen.dart#L68-73):
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
- **Qué hace exactamente:** En lugar de cerrar la pantalla de detalle actual y retornar a la instancia existente de la pantalla de inicio, ejecuta `Navigator.pushNamed(context, '/')`. Esto introduce un **nuevo** `HomeScreen` al tope de la pila de navegación.
- **Efecto en el stack de navegación:**
  - Si un usuario navega de Home a Detalles, y luego presiona "Back to home", y repite este proceso varias veces, la pila de pantallas crecerá indefinidamente: `Home (1) -> Detail (1) -> Home (2) -> Detail (2) -> Home (3)...`
  - **Consecuencias:**
    - **Fuga de memoria (Memory leak):** Cada pantalla apilada consume RAM para mantener su estado y widgets en memoria.
    - **Experiencia de usuario rota:** Cuando el usuario presione el botón físico de retroceso de su dispositivo Android o deslice para volver en iOS, en lugar de salir de la aplicación, tendrá que navegar en reversa a través de todas las pantallas duplicadas previamente creadas en la pila.
    - **Peticiones HTTP innecesarias:** Cada nueva instancia de `HomeScreen` que se añade a la pila ejecuta su `initState()`, lo que dispara una llamada de red adicional a la API de incidentes.

### 3c) ¿Cómo mejorarías el paso de datos?

Para mejorar el paso de datos entre las dos pantallas:
1. **Creación del modelo `Incident`:**
   ```dart
   class Incident {
     final String id;
     final String title;
     final String description;
     final String type;
     final String zone;
     final String status;
     final bool isFavorite;

     Incident({
       required this.id,
       required this.title,
       required this.description,
       required this.type,
       required this.zone,
       required this.status,
       this.isFavorite = false,
     });

     factory Incident.fromJson(Map<String, dynamic> json) {
       return Incident(
         id: json['id']?.toString() ?? '',
         title: json['title']?.toString() ?? 'Incidente sin título',
         description: json['description']?.toString() ?? 'Sin descripción',
         type: json['type']?.toString() ?? 'other',
         zone: json['zone']?.toString() ?? 'Zona no especificada',
         status: json['status']?.toString() ?? 'pending',
         isFavorite: false,
       );
     }
   }
   ```
2. **Paso de datos tipado:**
   - En `HomeScreen`, pasamos el objeto fuertemente tipado:
     ```dart
     Navigator.pushNamed(context, '/detail', arguments: incidentObject);
     ```
   - En `DetailScreen`, recuperamos y validamos el argumento de forma segura:
     ```dart
     final args = ModalRoute.of(context)?.settings.arguments;
     if (args is! Incident) {
       // Manejo defensivo en caso de error de navegación
       return const Scaffold(body: Center(child: Text('Error: Datos no válidos')));
     }
     final incidente = args;
     ```
- **Por qué reduce el riesgo:**
  - Evitamos excepciones de casteo a mapas genéricos que crashean la app.
  - El compilador garantiza la existencia de campos como `incidente.title` mediante autocompletado y tipado estático, eliminando el riesgo de errores ortográficos al acceder a propiedades.
  - La lógica de manejo de nulos y cambios de tipo de datos de la API se centraliza en la fábrica `fromJson`, aislando a los widgets de cualquier inestabilidad de la API.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

- **Cantidad:** Existen **2** instancias de `Dio` declaradas e inicializadas en la aplicación:
  1. En `home_screen.dart` (línea 10): `final Dio _dio = Dio();`
  2. En `detail_screen.dart` (línea 10): `final Dio _dio = Dio();` *(la cual ni siquiera se utiliza en la pantalla de detalle, ya que los datos se extraen de los argumentos de navegación).*
- **Problemas generados:**
  - **Desperdicio de recursos:** Se crea una instancia pesada de un cliente HTTP en la pantalla de detalles que consume memoria pero no realiza ninguna petición.
  - **Inconsistencia de configuración:** Si quisiéramos añadir interceptores, cabeceras personalizadas o modificar configuraciones globales de red, tendríamos que duplicar el código en cada archivo, aumentando drásticamente la probabilidad de introducir bugs.
  - **Falta de reutilización del pool de conexiones:** No compartir el cliente HTTP evita que las conexiones TCP existentes se mantengan activas (Keep-Alive), forzando al dispositivo a realizar un nuevo handshake de red por cada instancia de cliente.

### 4b) ¿Qué le falta a la configuración actual de Dio?

La configuración de `Dio` en `home_screen.dart` se reduce a: `final Dio _dio = Dio();` y se pasa la URL completa en el método `_dio.get(...)`. Le faltan al menos tres aspectos fundamentales:
1. **Definición de URL Base (`baseUrl`):** Pasar la URL completa en cada petición (`https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/incidents`) acopla el código a un servidor específico. Se debería definir una `baseUrl` global (`https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/`) de forma que los repositorios hagan llamadas con rutas relativas (ej. `/incidents`), facilitando cambiar de servidor para pruebas, desarrollo o producción.
2. **Definición de Tiempos de Espera (`timeouts`):** No se configuran `connectTimeout` ni `receiveTimeout`. Por defecto, Dio espera indefinidamente. Si la red es inestable o el servidor falla, el usuario quedará atrapado en un spinner de carga sin que la app lance un error de timeout.
3. **Manejo Centralizado de Errores e Interceptores:** No existe un interceptor global que procese códigos de error HTTP de forma centralizada (ej. refrescar sesión ante un error 401 Unauthorized, redirigir ante un 403, o registrar fallos de red en Crashlytics/Sentry). Tampoco hay un logger para depuración en desarrollo.

### 4c) Diseña cómo centralizarías Dio para toda la app

Centralizaría el cliente HTTP mediante un **Singleton** o registrándolo en un Localizador de Servicios como `GetIt`:

1. **Ubicación del archivo:** `lib/data/network/dio_client.dart`
2. **Estructura propuesta:**
   ```dart
   import 'package:dio/dio.dart';

   class DioClient {
     static final DioClient _instance = DioClient._internal();
     late final Dio dio;

     factory DioClient() => _instance;

     DioClient._internal() {
       dio = Dio(
         BaseOptions(
           baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/',
           connectTimeout: const Duration(seconds: 8),
           receiveTimeout: const Duration(seconds: 8),
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       );

       // Interceptores centralizados
       dio.interceptors.addAll([
         LogInterceptor(
           requestHeader: true,
           requestBody: true,
           responseBody: true,
         ),
       ]);
     }
   }
   ```
3. **Razonamiento:**
   - **Acceso Centralizado:** Las pantallas nunca interactúan con `DioClient` de forma directa. La capa de repositorios (ej. `IncidentRepository`) llamará a `DioClient().dio` para realizar peticiones HTTP de forma segura y uniforme.
   - **Mantenimiento Simple:** Cualquier cambio en los interceptores de red, headers o la URL base se realiza en un único archivo, garantizando la consistencia en toda la aplicación.

---

## Resumen de cambios que implementarás el miércoles

1. **Centralizar Dio (`DioClient`):** Crear el archivo `lib/data/network/dio_client.dart` con configuración de base URL, timeouts e interceptor de logs.
2. **Crear Modelo de Datos `Incident`:** Crear la clase modelo fuertemente tipada en `lib/models/incident.dart` con su fábrica `fromJson` para un mapeo robusto y seguro.
3. **Crear Capa de Repositorio (`IncidentRepository`):** Crear `lib/repositories/incident_repository.dart` para delegar el consumo y mapeo de datos de la API de forma aislada.
4. **Implementar Controlador de Estado (`IncidentController`):** Migrar las variables de estado y la lógica de filtrado fuera de `HomeScreen` hacia un controlador reutilizable y testeable.
5. **Corregir Navegación en `DetailScreen`:** Modificar la navegación de retroceso para usar `Navigator.pop(context)` en lugar de apilar una nueva instancia de `HomeScreen`.
6. **Refactorizar `DetailScreen` a `StatelessWidget`:** Eliminar la clase State innecesaria y gestionar el estado de favoritos en el controlador del negocio.
7. **Limpieza de `HomeScreen`:** Quitar la mutación de estado lateral `contadorRebuild++` de la fase de renderizado y modularizar la pantalla en sub-widgets limpios.
