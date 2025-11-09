# Patrón de diseño
Hemos optado por el patrón Model View ViewModel para la estructuración de la aplicación
# Diagramas
## Diagrama de clases
``` Mermaid
classDiagram
    class Usuario {
        +String ID
        +String Nombre
        +List~Gasto~ MisGastosPagados
        +List~Gasto~ MisGastosParticipados
    }
    
    class Amigo {
        +String ID
        +String Nombre
        +Decimal SaldoPendiente
    }
    
    class Gasto {
        +String ID
        +String Nombre
        +String Descripcion
        +Date Fecha
        +Decimal MontoTotal
        +Usuario Pagador
        +List~Participante~ Participantes
    }
    
    class Participante {
        +String UsuarioID
        +Decimal CantidadDebida
    }
    
    Usuario "1" <-- "0..*" Gasto
    Gasto "1" *-- "1..*" Participante
    Usuario "1" -- "0..*" Amigo

```

## Diagrama de secuencia (Crear gasto)
``` Mermaid
sequenceDiagram
    participant U as Usuario
    participant App as Aplicación Móvil
    participant DB as Base de Datos
    
    U->>App: Clic en botón "Gastos"
    App->>App: Muestra lista de gastos
    
    U->>App: Clic en botón "+"
    App->>App: Navega a "crear gasto"
    
    U->>App: Ingresa Description, Fecha, Monto
    U->>App: Selecciona Participantes
    
    U->>App: Clic en "Confirmar"
    
    App->>DB: Guarda nuevo Expense
    DB-->>App: Confirma guardado
    
    alt Error al guardar
        DB-->>App: Envía código de Error
        App->>U: Muestra "ERROR!"
    else Éxito al guardar
        App->>U: Muestra pantalla de Carga
        App->>App: Regresa a "Gastos"
        App->>U: Muestra lista de Expenses actualizada
    end
```

## Diagrama de flujo
``` Mermaid
graph TD
    A["Pantalla Principal"] --> B{"Menú: Friends / Expenses"};
    
    B --> C["Amigos"];
    B --> G["Gastos"];
    
    C --> D{"Ver Amigo"};
    C --> E{"Añadir Amigo"};
    C --> F{"Ir a Gastos"};
    
    D --> C2["Ver gastos de amigo X"];
    
    G --> H{"Ver Gasto"};
    G --> I{"Crear Gasto"};
    G --> J{"Ir a Amigos"};
    
    H --> G2["Ver usuarios de Expense X"];
    
    I --> K["Crear gasto"];
    K --> L{"Carga / Resultado"};
    
    C2 --> M["Modificar gasto"];
    M -->  L;
    
    G2 --> M;
    
    L --> B;
    L --> N["Pantalla de error"];
```