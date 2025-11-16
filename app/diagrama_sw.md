``` mermaid
classDiagram
    class Expense {
        +id: string
        +description: string
        +date: string
        +amount: float
        +totalCreditBalance: float
    }
    
    class Friend {
        +id: string
        +name: string
        +totalCreditBalance: float
        +totalDebitBalance: float
    }

    class Participation {
        <<Association>>
        +creditBalance: float
        +debitBalance: float
    }

    Friend "1..*" -- "0..*" Participation : (participa en)
    Expense "1" -- "1..*" Participation : (tiene participantes)
```

``` mermaid
graph TD
    A(Inicio) --> B(Ver Pantalla 'Friends' );
    B --> C{Acción del Usuario};
    C -- Clic 'EXPENSES' [cite: 21] --> D(Ver Pantalla 'Expenses' [cite: 54-65]);
    C -- Clic 'SHOW ALL' Amigo [cite: 12] --> E(Ver Detalle Amigo (UC-07) [cite: 38-44]);
    E --> B;
    
    D --> F{Acción del Usuario};
    F -- Clic 'FRIENDS'  --> B;
    F -- Clic 'SHOW ALL' Gasto [cite: 57] --> G(Ver Detalle Gasto (UC-05) [cite: 83-89]);
    G --> D;
    
    F -- Clic '+'  --> H(Ver Pantalla 'Crear Gasto' (UC-02) );
    H -- Rellenar Formulario  --> I(Clic 'CONFIRMAR' );
    I -- Gasto Creado  --> D;
    I -- Error Creación (A1, A2)  --> H;

    %% Flujo implícito de Edición/Borrado
    G -- Clic 'Editar' (Implícito, UC-03) --> J(Ver Pantalla 'Modificar Gasto' (UC-03) );
    J -- Clic 'CONFIRMAR' [cite: 133] --> K(Gasto Modificado [cite: 156]);
    K --> D;
    G -- Clic 'Eliminar' (Implícito, UC-04) --> L(Confirmar Eliminación [cite: 158]);
    L -- OK --> M(Gasto Eliminado [cite: 158]);
    M --> D;
    L -- Cancelar --> G;
```