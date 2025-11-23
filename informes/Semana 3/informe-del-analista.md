# Informe del Analista - Semana 3

**Analista:** [Nombre del miembro que ejerza este rol esta semana]

## Evaluación del Equipo

- **Evaluación Cuantitativa:**
    - Pedro Gómez: 5
    - Xabier Guitián: 5
    - Miguel Fraga: 5

- **Evaluación Cualitativa:**
    - **Todos los miembros (5/5):** El equipo ha funcionado como un reloj esta semana. La implementación de tests en Flutter puede ser compleja debido a la necesidad de simular el entorno (WidgetTester), y el equipo ha sabido dividir el problema eficazmente: unos centrados en la lógica de los datos falsos (Mocks) y otros en la interacción con los widgets. Se ha cumplido el objetivo de verificar tanto el éxito como el fracaso de las operaciones.

---

## Retrospectiva de la Semana 3 (Testing)

a) **¿Qué ha sido lo mejor de la práctica?**
   Lograr que los tests simulen errores de red (E/S) de forma controlada. Ver cómo el test pasa automáticamente al detectar que nuestra app muestra un mensaje de error ("Error de red simulado") nos da mucha confianza en la robustez del código.

b) **¿Qué fue lo peor?**
   La sintaxis de `flutter_test` y `WidgetTester`. Entender la diferencia entre `pump()` (avanzar un frame) y `pumpAndSettle()` (esperar a que terminen las animaciones) nos causó algunos fallos iniciales donde los tests intentaban pulsar botones que aún no estaban visibles.

c) **¿Cuál fue el mejor momento?**
   Ejecutar `flutter test` y ver todos los ticks verdes (Passed) por primera vez, confirmando que nuestros flujos de creación y validación funcionan tal como esperamos.

d) **¿Cuál ha sido el peor?**
   Configurar la inyección de dependencias para los tests. Tuvimos que refactorizar ligeramente cómo se inicia la app para poder "colar" nuestros repositorios falsos (Mocks) en lugar de los reales.

e) **¿Qué has aprendido?**
   Que el testing no es solo verificar que "todo va bien", sino verificar "qué pasa cuando todo va mal". Hemos aprendido a usar Mocks para simular escenarios que serían muy difíciles de reproducir manualmente (como que el servidor se caiga justo al guardar).

f) **¿Qué necesitáis conservar para el futuro?**
   La disciplina de pensar en los casos de error (edge cases) durante el desarrollo, no solo al final.

g) **¿Qué tenéis que mejorar?**
   Quizás aumentar la cobertura de tests para incluir flujos más complejos, como la edición de gastos o el cálculo de balances.

h) **Relación con la titulación:**
   Directamente relacionado con **Verificación y Validación de Software**. Hemos aplicado técnicas de pruebas de integración y caja negra sobre una interfaz gráfica.