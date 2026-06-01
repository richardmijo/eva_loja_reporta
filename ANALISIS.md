# Análisis de código — LojaReport

**Nombre:** Jhandry Alexis Jaramillo Peñafiel  
**Branch:** analisis/jhandry-jaramillo  
**Fecha:** 01/06/2026  
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

Sí, actualmente necesita ser un `StatefulWidget` porque mantengo la variable de estado local `favorito` (línea 12) y ejecuto un `setState(() => favorito = !favorito)` en el botón del marcador del `AppBar` (línea 31) para alternar el ícono. Si quitamos esa funcionalidad o guardamos el estado de los favoritos fuera del widget, podríamos cambiar perfectamente la pantalla a un `StatelessWidget`.

### 1b) El estado problemático

Vi varios problemas con el estado de `DetailScreen`:
1. **Pérdida de datos al navegar (estado efímero)**: La variable `favorito` es local. Si regreso al home y vuelvo a entrar al mismo incidente, la pantalla se recrea y el marcador vuelve a ser `false`.
2. **Código muerto**: Se declara `final Dio _dio = Dio();` en la línea 10 de `detail_screen.dart`, pero nunca se usa en ninguna parte del archivo.
3. **Mala extracción de parámetros**: Hago la conversión `final incidente = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;` dentro del método `build()`. Esto fuerza a extraer los datos en cada reconstrucción del widget, lo cual es ineficiente.

### 1c) ¿Qué cambiarías y por qué?

* Borraría la variable de `_dio` que no se está usando para nada.
* Extraería el estado de `favorito` a un gestor de estado global o a persistencia local (como `shared_preferences`) para no perder la información al cambiar de pantalla.
* Pasaría los datos del incidente mediante el constructor de la clase `DetailScreen` como un modelo fuertemente tipado en lugar de usar `ModalRoute` con mapas genéricos dentro del `build()`.
* Con estos cambios, convertiría `DetailScreen` en un `StatelessWidget` para que sea más liviano y limpio.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

Mi clase `_HomeScreenState` en [home_screen.dart](file:///c:/Users/Usuario/Desktop/eva_loja_reporta/lib/screens/home_screen.dart) está asumiendo demasiadas tareas a la vez:
1. **Llamadas de Red**: Crea la instancia de `Dio` y llama directamente a la API de MockAPI (líneas 25-48).
2. **Control de Errores**: Conoce y procesa las excepciones específicas de red (`DioException`).
3. **Lógica de Negocio**: Filtra los incidentes en memoria a través del getter `incidentesFiltrados` (líneas 50-53).
4. **Gestión de Estado**: Administra el estado local de carga (`cargando`), filtro seleccionado y lista de incidentes.
5. **Renderizado (UI)**: Define y dibuja la interfaz visual entera de la pantalla.

### 2b) El problema de tener Dio dentro del widget

* **Acoplamiento fuerte**: Si el backend cambia de URL o estructura, me veré obligado a modificar directamente mi archivo de vista (`home_screen.dart`).
* **Cero reutilización**: No puedo compartir esta lógica de conexión con otras pantallas de la app.
* **Dificultad de pruebas**: Se me hace casi imposible escribir pruebas unitarias para la lógica de red de forma independiente, ya que está atada al ciclo de vida del widget.

### 2c) Lo que no debería estar en build()

* **Efectos secundarios (Side Effects)**: La línea `contadorRebuild++;` (línea 57) no debería estar en `build()`. El método de renderizado debe ser puro y libre de alteraciones de variables externas ya que Flutter puede llamarlo en cualquier momento.
* **Widgets inline masivos**: Métodos auxiliares como `_buildTarjetaIncidente()` o `_buildBarraFiltros()` están dentro de la misma clase del widget, lo que provoca rebuilds globales innecesarios en vez de reconstruir por partes.
* **Lógica directa de filtrado** ejecutándose al vuelo cuando se construye la interfaz.

### 2d) Diseña la solución: cómo reorganizarías el código

Reorganizaría mi código en las siguientes carpetas y clases independientes:

1. **Capa de Datos**:
   * `IncidentModel`: Modelo con un constructor `fromJson` para parsear los datos de manera estructurada y segura.
   * `DioClient`: Un singleton centralizado para manejar todas las llamadas HTTP.
   * `IncidentRepository`: Clase que consume el cliente HTTP y retorna la lista de modelos `IncidentModel`.
2. **Capa de Lógica (Controlador)**:
   * `IncidentController`: Clase usando un gestor de estados (por ejemplo, `ChangeNotifier`) que se comunica con el repositorio, maneja los estados (cargando, error, lista) y realiza la lógica del filtro.
3. **Capa de Presentación (UI)**:
   * `HomeScreen`: Dibuja la UI escuchando al controlador.
   * Separar los componentes helper a widgets independientes como `IncidentCard` y `FilterBar` en archivos propios.

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

Estoy pasando los datos como un mapa genérico y sin tipado `Map<String, dynamic>` (usando `dynamic` al enviarlo).
**Riesgos:**
* **Falta de seguridad en compilación**: Si cometo un error de ortografía al llamar una propiedad (por ejemplo, `incidente['zonee']`), la app compilará sin quejar de nada pero fallará o saldrá vacío en tiempo de ejecución.
* **Acoplamiento estricto con la API**: Si el backend cambia la clave `zone` por `location`, mi aplicación se romperá al instante.
* **Repetición**: Me veo obligado a usar validaciones manuales `?? ''` por todo el código para protegerme contra valores nulos.

### 3b) El botón que hace algo cuestionable

El botón "Back to home" en `DetailScreen` (línea 69) hace lo siguiente:
`onPressed: () => Navigator.pushNamed(context, '/')`

**El problema:**
En lugar de cerrar la pantalla de detalle para volver atrás, estoy agregando una **nueva** pantalla de `HomeScreen` sobre la actual. Si el usuario repite esto varias veces, la pila de pantallas crecerá infinitamente, consumiendo toda la memoria del dispositivo (Memory Leak). Además, cada vez que hago este `push`, se ejecuta el `initState` de la nueva pantalla de home y se realiza una petición HTTP redundante a la API de MockAPI. 
**La solución** es usar simplemente `Navigator.pop(context);`.

### 3c) ¿Cómo mejorarías el paso de datos?

Creando un modelo fuertemente tipado llamado `Incident` con enums claros para mayor control:

```dart
class Incident {
  final String id;
  final String title;
  final String description;
  final String zone;
  final String type;
  final String status;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.zone,
    required this.type,
    required this.status,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      zone: json['zone'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
```

Al navegar, instanciaría el modelo y lo pasaría como argumento. Así, en `DetailScreen` recibiría un objeto `Incident` y podría acceder de forma segura a `incident.title` y `incident.zone`, con autocompletado y validaciones en tiempo de compilación.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Existen **2 instancias** independientes de `Dio` (una en `HomeScreen` y otra sin uso en `DetailScreen`).
**Problemas:**
* **Desperdicio de memoria y recursos**: Cada instancia crea y mantiene su propia cola de conexiones TCP socket de red.
* **Dificultad de mantenimiento**: Si quiero configurar cabeceras JWT, interceptores o cambiar el servidor, tengo que replicar y cambiar el código en múltiples archivos.

### 4b) ¿Qué le falta a la configuración actual de Dio?

Falta una configuración robusta de producción:
1. **URL Base (`baseUrl`)**: No está configurada, por lo que tengo que escribir la URL completa manualmente en cada request.
2. **Tiempos de espera (`timeouts`)**: Al no definir `connectTimeout` ni `receiveTimeout`, la app se quedará colgada cargando de forma infinita si el servidor está caído.
3. **Interceptores**: Para registrar en consola los logs de red o capturar de forma genérica errores globales (como un token vencido o pérdida de conexión).
4. **Cabeceras estándar** como el tipo de contenido JSON.

### 4c) Diseña cómo centralizarías Dio para toda la app

Crearía una clase Singleton para manejar una única instancia global de `Dio` en toda la app:

```dart
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
}
```

De esta manera, en mis repositorios solo tendría que usar `DioClient().dio` para realizar mis peticiones con las configuraciones compartidas.

---

## Resumen de cambios que implementarás el miércoles

1. **Declarar `dio` en `pubspec.yaml`**: Vi que importamos `package:dio/dio.dart` por todo el proyecto, pero no está declarado en las dependencias de `pubspec.yaml`. Debo agregarlo (`dio: ^5.7.0`) para que el proyecto pueda compilar y descargar sus paquetes sin errores.
2. **Corregir la navegación en `DetailScreen`**: Cambiaré `Navigator.pushNamed(context, '/')` por `Navigator.pop(context)` en el botón "Back to home" para liberar memoria del stack y solucionar la fuga de rutas.
3. **Limpiar código muerto en la vista detallada**: Eliminaré la instancia local `final Dio _dio = Dio();` de `DetailScreen` que está declarada pero no se usa en absoluto.
4. **Implementar el Modelo `Incident`**: Crearé una clase modelo estructurada con su respectivo constructor `fromJson` para parsear los datos JSON de la API de forma segura. Reemplazaré todos los accesos con mapas dinámicos (`Map<String, dynamic>`) por propiedades del modelo (ej. `incident.title` en lugar de `incidente['title']`).
5. **Crear el Singleton `DioClient`**: Centralizaré `Dio` en un solo archivo con URL base configurada, timeouts definidos para que la aplicación no se cuelgue al cargar datos, y un interceptor de logs para monitorizar las peticiones en fase de depuración.
6. **Desacoplar las llamadas de red (Capa de Datos)**: Crearé la clase `IncidentRepository` para extraer las peticiones HTTP fuera del widget `HomeScreen`, abstrayendo la llamada a la API.
7. **Implementar un Controlador de Estados**: Crearé `IncidentController` (usando `ChangeNotifier`) para gestionar la lógica de negocio, filtros y estados del flujo (cargando, error, lista), eliminando los `setState` pesados de `HomeScreen`.
8. **Optimizar la lista con `ListView.builder`**: Modificaré la forma en que se pintan los incidentes en `HomeScreen` (que actualmente usa `.map().toList()`) para usar `ListView.builder`, mejorando significativamente la velocidad de scroll y uso de memoria al reutilizar celdas.
9. **Eliminar efectos colaterales de renderizado**: Quitaré la instrucción `contadorRebuild++` de la fase del `build()` en `HomeScreen`, asegurando la inmutabilidad de la construcción de la interfaz.
10. **Modularizar los sub-widgets**: Extraeré componentes inline como las tarjetas (`IncidentCard`) y la barra de filtros (`FilterBar`) a archivos independientes dentro de una carpeta de widgets para limpiar los archivos principales.
