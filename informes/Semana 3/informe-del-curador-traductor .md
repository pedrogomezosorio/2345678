# Informe del Curador-Traductor - Semana 3

**Integrantes:**
* Pedro Gomez Osorio
* Xabier Guitian Lopez
* Miguel Fraga Pico

---

## 1. Objetivos de Aprendizaje (Tarea 3)

El objetivo de esta semana era asegurar la calidad del software mediante pruebas automatizadas. Como traductor, definí estos objetivos:

* **Tests End-to-End (Integración):** Entender la diferencia entre tests unitarios (probar una función) y tests de integración (probar un flujo completo en la UI). El objetivo era aprender a usar `WidgetTester` para interactuar con la app como si fuéramos un usuario (pulsar, escribir, scrollear).
* **Mocking e Inyección de Dependencias:** Aprender a aislar la UI de la base de datos/red. El objetivo era crear implementaciones falsas (`MockRepositories`) que cumplan la interfaz `IRepository` pero que nos permitan controlar las respuestas (devolver datos fijos o lanzar excepciones a voluntad).
* **Testing de Escenarios de Error:** Aprender a validar la resiliencia de la app. No basta con probar que guarda bien; el objetivo era automatizar la prueba de que la app *no crashea* y muestra un error legible cuando falla la red (Error E/S).
* **Testing de Validaciones:** Automatizar la comprobación de las reglas de negocio en la UI (ej. no permitir guardar un amigo sin nombre).

---

## 2. Recursos Empleados (Curador)

### 1. Guía de "Integration Testing" de Flutter

* **Descripción:** Documentación oficial sobre cómo probar widgets e interacciones.
* **Enlace:** `https://docs.flutter.dev/cookbook/testing/widget/introduction`
* **Utilidad:** Fue el manual de referencia para aprender la sintaxis básica: `find.text()`, `tester.tap()`, `tester.enterText()` y `expect()`.

### 2. Guía de "Mocking dependencies using Mockito" (Adaptada)

* **Descripción:** Aunque usamos mocks manuales por simplicidad, leímos sobre el concepto de Mocking para entender la teoría.
* **Enlace:** `https://docs.flutter.dev/cookbook/testing/unit/mocking`
* **Utilidad:** Nos ayudó a entender conceptualmente por qué necesitamos sustituir el `RestService` real por uno falso para que los tests sean rápidos, deterministas y no dependan de tener el servidor encendido.

### 3. Documentación de `Provider` (Testing)

* **Descripción:** Guías sobre cómo sobreescribir proveedores en tests.
* **Utilidad:** Clave para poder inyectar nuestros `MockFriendRepository` en la aplicación al arrancar el test, usando `Provider.value`, sin tener que modificar el código principal de la app (`main.dart`).