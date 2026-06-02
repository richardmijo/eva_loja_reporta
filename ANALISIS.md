# Análisis de código — LojaReport

**Nombre:** Kevin Michael Girón Chuquirima
**Branch:** analisis/kevin-giron
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

No completamente. En el archivo lib/screens/detail_screen.dart, el único estado que cambia es la variable favorito, utilizada para alternar el icono de marcador dentro del AppBar. Los datos del incidente se reciben mediante:
ModalRoute.of(context)!.settings.arguments y nunca cambian después de cargar la pantalla.
Por lo tanto, si la funcionalidad de favoritos se moviera a un gestor de estado o a un widget independiente, DetailScreen podría convertirse en un StatelessWidget.

### 1b) El estado problemático

En lib/screens/detail_screen.dart existe:
bool favorito = false;
Este estado es local y temporal.
El problema es que el valor no se persiste. Si el usuario sale de la pantalla o la aplicación se reinicia, el favorito vuelve a false. Además, el estado no representa una propiedad real del incidente sino únicamente del widget actual.

### 1c) ¿Qué cambiarías y por qué?

Movería la lógica de favoritos fuera de DetailScreen.
Crearía un modelo o servicio encargado de almacenar los incidentes favoritos y la pantalla únicamente consultaría ese estado.
Esto mejora la separación de responsabilidades, permite persistencia futura y reduce la necesidad de que DetailScreen sea un StatefulWidget.

---

## Pregunta 2 — Separación de responsabilidades

### 2a) ¿Qué responsabilidades tiene _HomeScreenState?

En lib/screens/home_screen.dart, la clase _HomeScreenState actualmente realiza varias tareas:

- Gestiona el estado visual de la pantalla.
- Realiza llamadas HTTP mediante Dio.
- Maneja errores de red.
- Almacena la lista de incidentes.
- Implementa la lógica de filtrado.
- Controla el indicador de carga.
- Gestiona la navegación hacia otras pantallas.

Esto concentra demasiadas responsabilidades en una sola clase.

### 2b) El problema de tener Dio dentro del widget

En _HomeScreenState se crea:
final Dio _dio = Dio();
El widget queda acoplado directamente a la capa de red.

Esto causa:

- Más difícil realizar pruebas unitarias.
- Más difícil reutilizar la lógica de consulta.
- La pantalla conoce detalles de infraestructura que deberían pertenecer a otra capa.

### 2c) Lo que no debería estar en build()

Dentro de build() aparece:
contadorRebuild++;

El método build() debe utilizarse únicamente para construir la interfaz.
Flutter puede ejecutar build() muchas veces por razones internas, por lo que modificar estado dentro de este método provoca comportamientos impredecibles y métricas incorrectas.

La lógica de negocio y las modificaciones de estado no deberían ejecutarse dentro de build().

### 2d) Diseña la solución: cómo reorganizarías el código

Crearía la siguiente estructura:
IncidentService

Responsable de las llamadas HTTP.
Método: Future<List<Incident>> obtenerIncidentes()

HomeScreen

Solo muestra información.
Solicita datos al servicio.
Gestiona la interacción visual.

ApiClient

Contiene la instancia única de Dio.
Configuración centralizada.

Flujo:

HomeScreen
    ↓
IncidentService
    ↓
ApiClient (Dio)
    ↓
API REST

---

## Pregunta 3 — Navegación y paso de datos

### 3a) ¿Qué tipo de dato se pasa entre pantallas y qué riesgo tiene?

En home_screen.dart se navega usando:

Navigator.pushNamed(
  context,
  '/detail',
  arguments: incidente,
);

El objeto incidente es de tipo:

Map<String, dynamic>

y luego se recupera mediante:

ModalRoute.of(context)!.settings.arguments
    as Map<String, dynamic>;

El riesgo es que no existe validación de tipos en tiempo de compilación.

Un error en una clave o un dato faltante provocaría errores durante la ejecución.

### 3b) El botón que hace algo cuestionable

En detail_screen.dart existe:

Navigator.pushNamed(context, '/');

para regresar al inicio, esto crea una nueva instancia de HomeScreen encima de la pila de navegación. Cada vez que se presiona el botón se agrega una pantalla adicional. Lo correcto sería:

Navigator.pop(context);

porque simplemente se desea regresar a la pantalla anterior.

### 3c) ¿Cómo mejorarías el paso de datos?

Crearía un modelo tipado:

class Incident {
  final String id;
  final String title;
  final String description;
  final String status;
  final String zone;
  final String type;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.zone,
    required this.type,
  });
}

Luego navegaría así:

Navigator.pushNamed(
  context,
  '/detail',
  arguments: incident,
);

y recibiría:

final incident =
    ModalRoute.of(context)!.settings.arguments as Incident;

De esta forma Flutter valida mejor los datos y se reduce el riesgo de errores por claves mal escritas.

---

## Pregunta 4 — Dio: configuración y reutilización

### 4a) ¿Cuántas instancias de Dio existen en la app y qué problema genera?

Actualmente existen al menos dos instancias:

En home_screen.dart:
final Dio _dio = Dio();

En detail_screen.dart:
final Dio _dio = Dio();

Además, la instancia de detail_screen.dart ni siquiera se utiliza.

Esto genera:

- Consumo innecesario de recursos.
- Configuraciones duplicadas.
- Mayor dificultad para mantener la aplicación.
- Posibles inconsistencias futuras.

### 4b) ¿Qué le falta a la configuración actual de Dio?

No existe configuración centralizada.
Faltan elementos como:

- Base URL.
- Timeouts.
- Interceptores.
- Manejo global de errores.
- Headers comunes.
- Logs de peticiones.

Actualmente la URL está escrita directamente dentro de: cargarIncidentes()
lo que dificulta el mantenimiento.

### 4c) Diseña cómo centralizarías Dio para toda la app

Crearía una clase:

ApiClient

Estructura propuesta:

lib/
 ├── models/
 │    └── incident.dart
 │
 ├── services/
 │    └── incident_service.dart
 │
 ├── network/
 │    └── api_client.dart
 │
 └── screens/
      ├── home_screen.dart
      ├── detail_screen.dart
      └── about_screen.dart

Todos los servicios reutilizarían la misma instancia de Dio creada por ApiClient.

---

## Resumen de cambios que implementarás el miércoles

1. Crear un modelo Incident para reemplazar los Map<String, dynamic>.
2. Crear un IncidentService para mover toda la lógica HTTP fuera de HomeScreen.
3. Centralizar la configuración de Dio mediante una única instancia compartida.
4. Reemplazar Navigator.pushNamed(context, '/') por Navigator.pop(context) y eliminar la instancia de Dio que no se utiliza en DetailScreen.