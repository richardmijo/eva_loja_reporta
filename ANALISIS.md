# Análisis de código — LojaReport

**Nombre:** Gabriel Sarango  
**Branch:** analisis/Gabriel-Sarango  
**Fecha:** 01 de Junio, 2026  
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

No. La única razón por la que DetailScreen es un StatefulWidget es para manejar el botón de "favorito" (línea 12). Si manejáramos los favoritos desde afuera (como debería ser), esta pantalla solo serviría para mostrar datos. Por lo tanto, debería ser un StatelessWidget, lo cual hace que el código sea más simple y la pantalla cargue más rápido.

### 1b) El estado problemático

El estado en DetailScreen tiene dos problemas principales:

1. **Los favoritos no se guardan (Línea 12):** La variable favorito solo vive mientras la pantalla está abierta. Si marcas un incidente, regresas al Home y vuelves a entrar, verás que ya no está marcado. Para que funcione, esto debe guardarse en una base de datos local o en un gestor de estado. 
2. **Hay código que no hace nada (Línea 10):** Se crea una instancia de Dio que jamás se usa en esta pantalla. Esto solo ensucia el código y gasta memoria sin motivo.

### 1c) ¿Qué cambiarías y por qué?

Para resolver estos problemas técnicos de manera profesional, implementaría los siguientes cambios:

1. **Convertir `DetailScreen` a un `StatelessWidget`:** Remover `StatefulWidget` y `_DetailScreenState`. La clase recibirá el incidente (idealmente un modelo tipado) a través de su constructor o mediante la extracción de argumentos en el `build()`.
2. **Eliminar la instancia muerta de Dio:** Borrar la línea `final Dio _dio = Dio();` del archivo `detail_screen.dart`.
3. **Elevar o Persistir el Estado de Favoritos:** 
   * **Opción A (Recomendada):** Crear un repositorio local o un servicio de persistencia (`FavoritesService`) usando `shared_preferences` o `Hive`, e inyectarlo en la capa de lógica.
   * **Opción B (Patrón BLoC / Provider):** Manejar los favoritos a través de un gestor de estado global (como `ChangeNotifier` o `Bloc`). La pantalla de detalle simplemente enviará un evento/acción de "toggle" y el estado se mantendrá consistente sin importar si la pantalla se destruye y reconstruye.
4. **Extraer argumentos de forma segura:** En lugar de `ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>`, deberíamos pasar un modelo fuertemente tipado `Incident` (ej. `arguments: incident`) para evitar posibles `NullPointerException` en tiempo de ejecución debido a cambios en la estructura de claves de la API.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

Actualmente, _HomeScreenState hace demasiadas cosas a la vez, lo que hace que el archivo sea difícil de leer y mantener:

1. Dibuja toda la interfaz de usuario (UI).
2. Guarda el estado de la pantalla (cargando, errores, filtros).
3. Se conecta directamente a internet usando Dio y maneja los errores de red.
4. Contiene la lógica para filtrar los incidentes.

### 2b) El problema de tener Dio dentro del widget

Tener el cliente HTTP y la lógica de red directamente acoplados al Widget Widget State tiene consecuencias muy negativas para la mantenibilidad:

1. **Imposible de Probar (Untestable):** No es posible realizar pruebas unitarias aisladas para la lógica de obtención de incidentes (`cargarIncidentes`) sin levantar todo el framework de Flutter y simular la UI, ya que la lógica HTTP está fuertemente atada al ciclo de vida del widget y a `setState`.
2. **Alto Acoplamiento a la Librería:** Si mañana se decide cambiar `Dio` por la librería nativa `http` de Dart, por GraphQL o por un backend local (caching/mocking), se tendría que reescribir y modificar directamente el código de la interfaz de usuario en `home_screen.dart`.
3. **Duplicación de Código e Instancias:** Se están creando múltiples clientes `Dio` a lo largo de la app (uno en `HomeScreen` y otro en `DetailScreen`). Esto impide la reutilización de conexiones TCP abiertas (Connection Pooling), configuraciones globales (timeouts, cabeceras) y cachés de red.
4. **Manejo de Errores Descentralizado:** Cada widget debe duplicar el bloque `try-catch`, formatear su propio mensaje de error y manejar de manera redundante los códigos de estado HTTP en lugar de tener un interceptor global de errores.

### 2c) Lo que no debería estar en build()

Hay dos cosas muy peligrosas dentro del build() de HomeScreen:

1. **Sumar al contador (Línea 57):** Modificar variables (como contadorRebuild++) dentro del build es un error. Flutter redibuja las pantallas muchas veces por distintos motivos; hacer esto puede causar inconsistencias graves o ciclos infinitos.
2. **Cargar toda la lista de golpe (Línea 149 - 153):** Usar un ListView normal con .toList() obliga a la app a dibujar todos los incidentes a la vez en la memoria. Si la API devuelve 500 incidentes, la app se pondrá muy lenta. Lo correcto es usar ListView.builder para que solo cargue los que se ven en pantalla.

### 2d) Diseña la solución: cómo reorganizarías el código

Para lograr una arquitectura limpia y desacoplada, reorganizaría el código siguiendo el patrón **MVVM** o una arquitectura por **Capas (Clean Architecture)**:

1. **Capa de Modelo (Entities):**
   Crear la entidad `Incident` para tipar fuertemente las respuestas:
   * Archivo: `lib/models/incident_model.dart` con la clase `Incident` y un constructor de fábrica `Incident.fromJson()`.
2. **Capa de Datos (Data & Network):**
   * **`ApiClient` (Singleton):** Centraliza la instancia de `Dio` con configuraciones globales (`baseUrl`, `connectTimeout`, interceptores).
   * **`IncidentRepository`:** Clase encargada únicamente de consultar datos remotos.
     * Método: `Future<List<Incident>> fetchIncidents();`
3. **Capa de Lógica de Negocio / Presentación (Controller/State):**
   * Crear un controlador o notificador de estado usando `ChangeNotifier` (u otro gestor de estado):
     * Archivo: `lib/controllers/incident_controller.dart`
     * Atributos: `List<Incident> _incidents`, `bool _isLoading`, `String _error`, `String _currentFilter`.
     * Métodos: `Future<void> loadIncidents()`, `void setFilter(String filter)`.
     * Getters: `List<Incident> get filteredIncidents`.
4. **Capa de Interfaz de Usuario (UI):**
   * **`HomeScreen`** se convierte en un widget limpio que solo escucha al controlador.
   * Utilizar `ListView.builder` para renderizar los elementos bajo demanda.
   * Extraer `_buildTarjetaIncidente` a su propio widget independiente (`IncidentCardTile`) en la carpeta `lib/widgets/` para maximizar su reutilización y legibilidad.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Se está pasando un Map<String, dynamic> genérico (línea 199).

El riesgo de hacer esto es que Dart no te avisa si te equivocas. Si escribes mal el nombre de un campo (por ejemplo, incidente['titlo'] en lugar de title), la app no mostrará error al programar, pero se romperá cuando el usuario la esté usando.

### 3b) El botón que hace algo cuestionable

El botón de retroceso en detail_screen.dart (líneas 68 - 73) usa Navigator.pushNamed(context, '/').

Esto es un gran error porque en lugar de cerrar la pantalla de detalle, está abriendo una nueva pantalla Home encima. Si el usuario va y viene varias veces, se acumularán decenas de pantallas abiertas en la memoria, poniendo lenta la app y dañando el funcionamiento del botón físico de "Atrás" del celular.

### 3c) ¿Cómo mejorarías el paso de datos?

Cambiaría el botón de retroceso para que use Navigator.pop(context). Esto sí cierra la pantalla correctamente.

Crearía una clase Incidente con todas sus propiedades bien definidas.

Al navegar a los detalles, pasaría este objeto Incidente en lugar de un Map. Así me aseguro de que los datos son correctos.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Existen dos instancias de Dio: una en HomeScreen y otra en DetailScreen (que ni se usa).

El problema es que estamos repitiendo código y desperdiciando recursos. Al tener varios clientes de red, no podemos compartir configuraciones entre ellos, y la app abre más conexiones de internet de las necesarias.

### 4b) ¿Qué le falta a la configuración actual de Dio?

El Dio() actual está totalmente vacío. Le falta:

1. URL Base (baseUrl): Para no tener que escribir la dirección completa en cada petición.
2. Tiempos de espera (Timeouts): Si el internet del usuario está lento, la app se quedará cargando para siempre. Hay que ponerle un límite de tiempo.
3. Cabeceras estándar: Falta especificar que estamos enviando y recibiendo datos en formato JSON.

### 4c) Diseña cómo centralizarías Dio para toda la app

Para centralizar e industrializar el uso de `Dio`, crearía una clase cliente utilizando el **Patrón Singleton** o a través de **Inyección de Dependencias** (`GetIt` / `Provider`), organizándola de la siguiente manera:
```dart
class ApiClient {
  ApiClient._internal();
  
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late final Dio dio;
  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1',
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // Añadir interceptores globales
    dio.interceptors.addAll([
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
      InterceptorsWrapper(
        onError: (DioException error, handler) {
          // Centralizar tratamiento de códigos HTTP como 401, 403, 500
          print('Ocurrió un error en red: ${error.message}');
          return handler.next(error);
        },
      ),
    ]);
  }
}
```
Esta clase se inicializa en el `main.dart` mediante `ApiClient().init();` y los repositorios la consumen directamente a través de la propiedad estática, garantizando una única y óptima conexión compartida.


## Resumen de cambios que implementarás el miércoles

1. **Diseñar el Modelo de Datos Fuertemente Tipado (`Incident`):** Crear una clase Dart formal para estructurar y validar con seguridad el JSON recibido de la API, eliminando los mapas dinámicos inseguros.
2. **Implementar el Cliente HTTP Centralizado (`ApiClient`):** Configurar `Dio` con el patrón Singleton, estableciendo cabeceras predeterminadas, URL base y timeouts preventivos.
3. **Adoptar una Arquitectura de Desacoplamiento (MVVM):** Migrar el consumo de API a la capa de datos (`IncidentRepository`) y el estado a la capa lógica (`IncidentController` con `ChangeNotifier`), limpiando a las vistas de responsabilidades impropias.
4. **Refactorizar y Optimizar la Interfaz Gráfica (UI):** Convertir `DetailScreen` en un `StatelessWidget`, optimizar `HomeScreen` sustituyendo el ListView mapeado por un eficiente `ListView.builder` para renderizado bajo demanda, y reparar la navegación recursiva a Home aplicando el método `Navigator.pop(context)`.