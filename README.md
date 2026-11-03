# 💰 Gestor de gastos 50/30/20

**Control de finanzas personales con lógica 100% declarativa**

Aplicación para llevar el control de las finanzas personales, desarrollada como proyecto final de **Programación Declarativa**. Toda la lógica está escrita en **Prolog** y la interfaz en **Streamlit**.

| | |
|---|---|
| **Autora** | [tu nombre] |
| **Grupo** | [tu grupo] |
| **Profesora** | [nombre de la profesora] |
| **Entrega** | 11 de diciembre |

---

## 📖 1. Descripción

El usuario registra sus ingresos y sus gastos del día a día. La aplicación los organiza, genera un informe mensual, compara cada mes con el anterior, emite alertas, administra una o varias **cuentas de ahorro** y ayuda a cumplir metas de ahorro.

> **Idea central:** los datos se guardan y todo lo demás se deduce. Un total, un porcentaje, una comparación o el saldo de una cuenta no se almacenan: se calculan cuando se piden, a partir de los hechos. Así nunca quedan desactualizados ni contradicen a los datos.

Los gastos se clasifican en dos categorías, y el ahorro es lo que queda:

| Concepto | Qué es | Meta por defecto (% del ingreso) |
|---|---|---|
| 🛒 Necesidad | mercado, médico, alquiler, transporte | 50% |
| 🎉 Deseo | restaurantes, ocio, compras no esenciales | 30% |
| 🐖 Ahorro del mes | dinero que queda: ingresos menos gastos | 20% |

El usuario puede cambiar los porcentajes y definir sus propias reglas.

---

## 🧠 2. Modelo de datos: base de datos deductiva

El proyecto funciona como una **base de datos deductiva**: una parte de **hechos** que se guardan y otra de **reglas** que deducen información a partir de ellos.

### 2.1 Hechos (lo que se guarda)

Son predicados dinámicos (`:- dynamic`). El usuario los cambia con `assert` y `retract` mientras la aplicación corre.

| Predicado | Argumentos | Estado |
|---|---|---|
| `expenses/6` | `Year, Month, Day, Description, Monto, Category` (`necesidad` o `deseo`) | ✅ Implementado |
| `incomes/6` | `Year, Month, Day, Description, Monto, Type` (`salario` o `ingreso_extra`) | ✅ Implementado |
| `ajuste_ahorro/4` | `Year, Month, Day, Monto` (positivo o negativo) | 🕓 Previsto |
| `cuenta_ahorro/1` | `Nombre` | 🕓 Previsto |
| `reparto_ahorro/4` | `Cuenta, Porcentaje, Year, Month` (vigente desde ese mes) | 🕓 Previsto |
| Reglas del usuario | porcentajes meta, límites, clasificación automática, meta de ahorro | 🕓 Previsto |

> **Criterio de diseño:** lo que es un conjunto pequeño y cerrado (categorías, tipos de ingreso) se guarda como **átomo** (`necesidad`). El texto libre (descripciones) se guarda como **cadena** (`"Super mercado"`).

### 2.2 Reglas (lo que se deduce)

No se guardan: se calculan.

| Predicado | Qué calcula |
|---|---|
| `total_gastos/3`, `total_gasto_por_categoria/4` | Total gastado en un mes, o por categoría |
| `total_ingresos/3`, `total_ingreso_por_tipo/4` | Total ingresado en un mes, o por tipo |
| `dinero_restante/3` | Ingresos menos gastos del mes (el ahorro del mes) |
| `porcentaje_gasto_por_categoria/4`, `porcentaje_gasto_total/3`, `porcentaje_ahorro/3` | Porcentaje del ingreso |
| `compare_expenses/4`, `compare_income/4`, `compare_savings/4` | Diferencia con el mes anterior y mensaje |
| `compare_with_lastmonth/6`, `summ_list_table/4`, `compare_result/2` | Piezas genéricas de las comparaciones |

### 2.3 Restricciones de integridad

Las reglas también vigilan que los datos sean coherentes. Por ejemplo, que los porcentajes de reparto entre las cuentas de ahorro sumen 100, o que no existan dos cuentas con el mismo nombre. Son predicados que se consultan antes de aceptar un cambio.

---

## ✨ 3. Funcionalidades

### 📝 Registro
- Registrar el ingreso mensual (salario).
- Registrar ingresos extras con fecha y descripción.
- Registrar gastos diarios con fecha, descripción, monto y categoría.
- Clasificación automática de la categoría según las reglas del usuario.

### 📅 Historial
- Ver los movimientos de un mes.
- Filtrar por categoría (necesidad o deseo).

### 📊 Informe mensual
- Ingreso total del mes (salario más extras).
- Total gastado y dinero restante.
- Porcentaje del ingreso en cada categoría frente a la meta.
- Monto y porcentaje ahorrado.
- Día del mes en que más se gastó.

### 🔄 Comparación con el mes anterior
- Diferencia en el gasto total y en el de cada categoría.
- Diferencia en los ingresos y en el ahorro entre ambos meses.
- Si el mes es enero, se compara con diciembre del año anterior.

### 🏦 Cuentas de ahorro
Ver la sección 4.

### 🚨 Alertas
El sistema avisa cuando:
- Se gastó más de lo que se ganó en el mes.
- Una categoría superó su porcentaje meta.
- Se ahorró menos de lo propuesto.
- El saldo de una cuenta de ahorro quedó en negativo.
- Se incumple una regla definida por el usuario.

### ⚙️ Reglas configurables
El usuario puede ver, agregar y eliminar reglas de estos tipos:

| Tipo de regla | Ejemplo |
|---|---|
| Cambiar los porcentajes meta | 60% necesidades, 25% deseos, 15% ahorro |
| Límite mensual por categoría | Deseos: máximo 200 al mes |
| Máximo de veces por tipo de gasto | Restaurante: máximo 3 veces al mes |
| Clasificación automática | "Restaurante" siempre es un deseo |
| Meta de ahorro | Ahorrar al menos 100 al mes |

### 🎯 Planificador de metas de ahorro
El usuario indica una meta y un plazo, por ejemplo: *"quiero ahorrar 100.000 en 4 meses"*. El sistema:

1. Calcula el ahorro mensual necesario.
2. Lo compara con lo que el usuario ahorra actualmente.
3. Si falta, propone recortes por prioridad (primero deseos, luego necesidades).
4. Verifica si la meta es alcanzable y, si no, sugiere un plazo mayor.
5. Devuelve una **lista de pasos** para lograrla.

---

## 🏦 4. Cuentas de ahorro

Hay que distinguir dos cosas:

| | Qué es |
|---|---|
| **Ahorro del mes** | Lo que queda ese mes (`dinero_restante`) |
| **Cuenta de ahorro** | El acumulado. Cada mes le suma el sobrante. Si un mes se gasta más de lo que se ganó, el déficit se le resta |

### 4.1 Cuenta única

El saldo hasta un mes se deduce, no se guarda:

> **saldo = ingresos hasta ese mes − gastos hasta ese mes + ajustes hasta ese mes**

- La cuenta **empieza con el primer dato registrado**. Los meses sin datos aportan 0.
- Un mes con déficit resta solo, sin ninguna condición: el cálculo es el mismo.
- Si el saldo queda en negativo, salta una alerta.

### 4.2 Ajustes del usuario

Si el usuario se equivoca, o ya tenía ahorros antes de usar la aplicación, indica el saldo real. El sistema calcula la **diferencia** con el saldo calculado y la guarda como un hecho `ajuste_ahorro/4`, con su fecha.

El historial nunca se modifica: solo se añaden hechos nuevos, así se ve cuándo y de cuánto fue cada corrección.

> La fecha la entrega la aplicación (Streamlit) como argumento. Prolog no lee el reloj, de modo que los predicados siempre dan el mismo resultado para los mismos datos y son fáciles de probar.

### 4.3 Varias cuentas

El usuario puede crear varias cuentas y asignarle a cada una el porcentaje del ahorro del mes que le corresponde. Los porcentajes de todas las cuentas deben sumar 100.

- Cada porcentaje se guarda con el mes desde el que rige (`reparto_ahorro/4`).
- El porcentaje vigente de una cuenta en un mes es el de la entrada más reciente cuyo inicio sea anterior o igual a ese mes.
- Cambiar un porcentaje **añade** una entrada nueva y no borra las anteriores, así los meses pasados se mantienen intactos.

---

## 🛠️ 5. Tecnologías

| Componente | Tecnología | Función |
|---|---|---|
| Lógica | SWI-Prolog 9 o superior (probado con 10.0.2) | Hechos, reglas, cálculos, comparaciones, alertas, cuentas y plan de ahorro |
| Interfaz | Streamlit (Python) | Formularios, tablas y gráficas |
| Conexión | Janus (`janus-swi`) | Permite a Python consultar a Prolog |
| Almacenamiento | Archivos de hechos de Prolog | Guardan los datos entre sesiones |

> La interfaz solo muestra información y recoge datos. Todo cálculo y toda decisión se hacen en Prolog.

---

## 🎓 6. Conceptos de programación declarativa que se aplican

| Concepto | Dónde se ve en el proyecto |
|---|---|
| Hechos y reglas | `expenses/6`, `incomes/6` y todos los totales |
| Consultas y backtracking | Filtrar gastos por categoría o mes con variables libres |
| Listas y recursión | Sumas y planificador de ahorro |
| Selección de casos sin `if` | Cláusulas con guardas (`compare_result/2`, enero frente a otros meses) |
| Aritmética | `is`, comparaciones, porcentajes |
| Negación | Alertas ("no se superó el límite") |
| Predicados de segundo orden | `findall` para juntar montos; `bagof` y `setof` para agrupar |
| Metaprogramación | `assert` y `retract` para datos y reglas; `call` para pasar un predicado como argumento |
| Base de datos deductiva | Hechos dinámicos y reglas que deducen todo lo demás |
| Entrada y salida con archivos | Guardar y cargar datos entre sesiones |

Predicados de la librería de SWI-Prolog que se usan: `sum_list/2`, `call/N` (con argumentos adicionales) y `format/3`.

---

## 📁 7. Estructura del proyecto

```
Gestor-de-gastos/
├── README.md
├── requirements.txt
├── .gitignore
│
├── app/                          # Interfaz en Streamlit
│   ├── main.py                   # Página principal
│   ├── puente_prolog.py          # Llamadas a Prolog con Janus
│   └── pages/                    # Una página por pantalla
│
├── prolog/                       # Toda la lógica
│   ├── main.pl                   # Carga todos los módulos
│   ├── datos.pl                  # Hechos dinámicos, guardar y cargar
│   ├── operations/
│   │   ├── expenses.pl           # Totales, porcentajes y comparación de gastos
│   │   ├── income.pl             # Totales y comparación de ingresos
│   │   ├── savings.pl            # Dinero restante y cuentas de ahorro
│   │   └── auxiliary_methods.pl  # Piezas genéricas de las comparaciones
│   ├── alertas.pl                # Alertas
│   ├── comparacion.pl            # Comparación entre meses
│   ├── reglas.pl                 # Reglas configurables del usuario
│   └── plan_ahorro.pl            # Planificador de metas de ahorro
│
├── datos/                        # Datos guardados por la aplicación
├── tests/                        # Pruebas de la lógica (plunit)
│   └── tests.pl
└── docs/                         # Propuesta e informe
```

---

## 📐 8. Convenciones de código

- Cada predicado hace **una sola cosa** y reutiliza a los demás. Los cálculos que se repiten, como sumar una tabla, viven en un solo sitio.
- Orden de los argumentos: **entradas primero y resultado al final**, por ejemplo `(Year, Month, Total)`. Las excepciones son los totales por categoría o por tipo, que reciben la categoría o el tipo en primer lugar.
- Los casos distintos se escriben como **cláusulas distintas del mismo predicado**, con una guarda cuando haga falta (`Month > 1`), no como condicionales.
- Los resultados se calculan. Solo se guarda lo que el usuario introduce.
- Cada archivo carga lo que necesita con `:- ensure_loaded(...)`.

---

## ⚙️ 9. Instalación

**Requisitos**

- SWI-Prolog 9 o superior (swi-prolog.org). Durante la instalación, marcar la opción de añadir `swipl` al PATH.
- Python 3.10 o superior.
- En Windows, las **Microsoft C++ Build Tools** (carga de trabajo "Desktop development with C++"), necesarias para compilar `janus-swi`.

**Pasos**, desde la carpeta del proyecto:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

El archivo `requirements.txt` incluye `streamlit` y `janus-swi`.

Si PowerShell bloquea la activación del entorno, ejecutar antes:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

---

## ⌨️ 10. Comandos habituales

### Entorno

```powershell
.\.venv\Scripts\Activate.ps1      # Activar el entorno (aparece (.venv) al inicio)
deactivate                        # Desactivarlo
swipl --version                   # Versión de SWI-Prolog
pip install -r requirements.txt   # Instalar dependencias
python -c "import janus_swi as j; print(j.query_once('X is 2+3'))"   # Probar Janus
```

La prueba de Janus debe mostrar `{'truth': True, 'X': 5}`.

### Ejecutar

```powershell
swipl prolog/main.pl                    # Lógica completa
swipl prolog/operations/savings.pl      # Un archivo suelto
streamlit run app/main.py               # Interfaz
```

### Dentro de la consola de Prolog

```prolog
?- make.                       % Recargar los archivos modificados
?- listing(nombre/aridad).     % Ver las cláusulas que Prolog tiene cargadas
?- list_undefined.             % Buscar predicados llamados que no existen
?- time(consulta).             % Medir el coste de una consulta
?- halt.                       % Salir
```

Con `;` se pide la siguiente solución y con Enter se termina. Para leer un error, buscar el archivo y la línea (`archivo.pl:25:`).

### Pruebas

```powershell
swipl -g run_tests -t halt tests/tests.pl    # Ejecutar las pruebas plunit
```

### Control de versiones

Con GitHub Desktop: revisar los cambios, escribir un resumen corto, **Commit to main** y después **Push origin**.

---

## ✅ 11. Datos de comprobación

Con los datos de prueba de marzo de 2026 que hay en `prolog/datos.pl` (ingresos 1700, gastos 800):

| Consulta | Resultado |
|---|---|
| `dinero_restante(2026, 3, T)` | `900` |
| `total_gasto_por_categoria(necesidad, 2026, 3, T)` | `300` |
| `total_gastos(2026, 3, T)` | `800` |
| `total_ingresos(2026, 3, T)` | `1700` |
| `porcentaje_gasto_por_categoria(deseo, 2026, 3, P)` | ≈ 29,4 |
| `porcentaje_gasto_total(2026, 3, P)` | ≈ 47,1 |
| `porcentaje_ahorro(2026, 3, P)` | ≈ 52,9 |
| `compare_savings(2026, 3, R, M)` | `R = 900`, mensaje de aumento |

> El porcentaje de gasto total y el de ahorro deben sumar 100.

---

## 🧭 12. Decisiones de diseño y puntos abiertos

**Decididas**

- Los totales, porcentajes, comparaciones y saldos **se calculan siempre**. El coste es despreciable para una sola persona usuaria.
- El ahorro del mes es el dinero que queda, y sigue siendo del usuario.
- Los ajustes de la cuenta se guardan como diferencias con fecha.
- Un cambio de porcentaje en el reparto rige desde el mes en que se hace.

**Por decidir**

- Si la categoría `ahorro` se mantiene como tipo de gasto o se elimina, ya que el ahorro es lo que queda.
- Si el saldo de la cuenta cuenta solo los meses cerrados o también muestra un valor provisional del mes en curso.
- De qué cuenta se descuenta un déficit cuando hay varias (por ejemplo, en proporción al reparto vigente).
- Si `comparacion.pl` se usa o se elimina, ya que las comparaciones viven hoy en `operations/`.

---

## 🚦 13. Estado del proyecto

- [x] Instalación y prueba de conexión Python con Prolog
- [x] Hechos básicos de gastos e ingresos
- [x] Totales, porcentajes y dinero restante
- [x] Comparación con el mes anterior (gastos, ingresos y ahorro)
- [ ] Cuenta de ahorro con ajustes
- [ ] Día de mayor gasto e historial con filtros
- [ ] Alertas
- [ ] Reglas configurables y guardado en archivo
- [ ] Varias cuentas de ahorro con reparto por porcentaje
- [ ] Planificador de metas de ahorro
- [ ] Interfaz en Streamlit
- [ ] Pruebas
- [ ] Informe final y exposición

---

## 🗓️ 14. Plan de trabajo

| Semana | Fechas | Actividad |
|---|---|---|
| 1 | 2 al 8 de nov. | Totales, porcentajes y comparaciones (hecho). Cuenta de ahorro simple con ajustes |
| 2 | 9 al 15 de nov. | Día de mayor gasto, historial con filtros y alertas |
| 3 | 16 al 22 de nov. | Reglas configurables, guardado en archivo e interfaz mínima con Janus |
| 4 | 23 al 29 de nov. | Varias cuentas de ahorro con reparto por porcentaje |
| 5 | 30 de nov. al 6 de dic. | Planificador de metas de ahorro e interfaz completa |
| 6 | 7 al 11 de dic. | Pruebas, informe y exposición |

> Si hay que recortar, lo esencial son los datos, los cálculos, las comparaciones, las alertas y las cuentas de ahorro. El planificador de metas y los detalles de la interfaz son lo primero que se simplifica.

---

## 📌 15. Alcance

- Una sola persona usuaria.
- Datos guardados en archivos locales.
- Sin cuentas de usuario, conexión a bancos ni conversión de monedas.
- Las reglas configurables son de tipos predefinidos con parámetros que elige el usuario.
