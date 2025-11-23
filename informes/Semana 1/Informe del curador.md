# Informe del Curador-Traductor

## Objetivos de aprendizaje de la semana 1

* **Concepto: Patrones Arquitectónicos (MVVM)**
    * Entender la necesidad de un patrón arquitectónico para separar la interfaz gráfica (Vista) de la lógica de estado (Modelo/ViewModel), tal como lo exige el `enunciado.md`.
    * El objetivo fue seleccionar un patrón adecuado (MVVM) e implementarlo usando las herramientas de Flutter.
    * **Recursos indentificados para su estudio:** Documentación oficial de Flutter sobre gestión de estado, específicamente el paquete `provider`.

* **Herramienta: Diseño de Software (UML y Mermaid)**
    * Aprender a modelar la aplicación creando los diagramas estáticos (clases) y dinámicos (secuencia, flujo) solicitados.
    * Dominar la sintaxis de la herramienta **Mermaid** para documentar este diseño de forma efectiva en el fichero `diseño_sw.md`.
    * **Recursos indentificados para su estudio:** Editor en vivo y documentación oficial de Mermaid (mermaid.js.org).

* **Concepto: Diseño de Interfaz Adaptativa**
    * Aprender a diseñar una interfaz de usuario apropiada para un dispositivo móvil que cubra todos los casos de uso.
    * El diseño debe ser adaptativo, diferenciando claramente entre teléfonos y tablets, e incluir retroalimentación para errores y E/S.
    * **Recursos indentificados para su estudio:** Guías de Material Design (para Flutter) y Apple Human Interface Guidelines (HIG).

## Recursos empleados en la semana 1

* **Descripción del recurso:** Documentación oficial de **Flutter sobre gestión de estado**, complementada con la documentación del paquete `provider`.
    * **Utilidad y aplicación a la práctica:** Este recurso fue **conceptual y técnico**. Se usó para justificar la elección del patrón MVVM y para implementarlo conectando el `FriendViewModel` (que usa `ChangeNotifier`) con la `FriendsScreen` (la Vista), cumpliendo el requisito de separar la vista del estado.

* **Descripción del recurso:** **Editor en vivo y documentación de Mermaid (mermaid.js.org)**.
    * **Utilidad y aplicación a la práctica:** Fue una herramienta **práctica y directa**. Se utilizó para escribir, probar y exportar el código de los diagramas de clase, secuencia y flujo exigidos por el `enunciado.md`, asegurando que el entregable `diseño_sw.md` se visualice correctamente en GitHub.

* **Descripción del recurso:** **Guías de diseño de Material Design (material.io)**.
    * **Utilidad y aplicación a la práctica:** Este recurso fue **conceptual y de diseño**. Sirvió de base para crear los *wireframes* presentados en `diseño-iu.pdf`, ya que Flutter usa Material Design como base. Fue esencial para cumplir el requisito de diseño adaptativo (móvil vs. tablet) y para diseñar los estados de retroalimentación (carga y error).