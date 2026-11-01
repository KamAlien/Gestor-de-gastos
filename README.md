# Gestor de gastos 50/30/20

Aplicación para llevar el control de las finanzas personales, desarrollada como proyecto final de **Programación Declarativa**. Toda la lógica está escrita en **Prolog** y la interfaz en **Streamlit**.

**Autora:** [Kamila Reinoso Asin]
**Grupo:** [C311]
**Profesora:** [Lia]
**Fecha de entrega:** 11 de diciembre

---

## 1. Descripción

El usuario registra sus ingresos y sus gastos del día a día. La aplicación los organiza, genera un informe mensual, compara el mes actual con el anterior, emite alertas y ayuda a cumplir metas de ahorro.

Los gastos se clasifican en tres categorías:

| Categoría | Ejemplos | Meta por defecto (% del ingreso) |
|---|---|---|
| Necesidad | mercado, médico, alquiler, transporte | 50% |
| Deseo | restaurantes, ocio, compras no esenciales | 30% |
| Ahorro | dinero que se aparta | 20% |

El usuario puede cambiar los porcentajes y definir sus propias reglas.

## 2. Funcionalidades

### Registro
- Registrar el ingreso mensual (salario).
- Registrar ingresos extras con fecha y descripción.
- Registrar gastos diarios con fecha, descripción, monto y categoría.
- Clasificación automática de la categoría según las reglas del usuario.

### Historial
- Ver los movimientos de un mes.
- Filtrar por categoría (necesidad, deseo o ahorro).

### Informe mensual
- Ingreso total del mes (salario más extras).
- Total gastado y dinero restante.
- Porcentaje del ingreso en cada categoría frente a la meta.
- Monto y porcentaje ahorrado.
- Día del mes en que más se gastó.

### Comparación con el mes anterior
- Diferencia en el gasto total y en el de cada categoría.
- Diferencia en el ahorro entre ambos meses.

### Alertas
El sistema avisa cuando:
- Se gastó más de lo que se ganó en el mes.
- Una categoría superó su porcentaje meta.
- Se ahorró menos de lo propuesto.
- Se incumple una regla definida por el usuario.

### Reglas configurables
El usuario puede ver, agregar y eliminar reglas de estos tipos:

| Tipo de regla | Ejemplo |
|---|---|
| Cambiar los porcentajes meta | 60% necesidades, 25% deseos, 15% ahorro |
| Límite mensual por categoría | Deseos: máximo 200 al mes |
| Máximo de veces por tipo de gasto | Restaurante: máximo 3 veces al mes |
| Clasificación automática | "Restaurante" siempre es un deseo |
| Meta de ahorro | Ahorrar al menos 100 al mes |

### Planificador de metas de ahorro
El usuario indica una meta y un plazo, por ejemplo: *"quiero ahorrar 100.000 en 4 meses"*. El sistema:
1. Calcula el ahorro mensual necesario.
2. Lo compara con lo que el usuario ahorra actualmente.
3. Si falta, propone recortes por prioridad (primero deseos, luego necesidades).
4. Verifica si la meta es alcanzable y, si no, sugiere un plazo mayor.
5. Devuelve una **lista de pasos** para lograrla.

## 3. Tecnologías

| Componente | Tecnología | Función |
|---|---|---|
| Lógica | SWI-Prolog 9 o superior | Datos, cálculos, comparaciones, reglas, alertas y plan de ahorro |
| Interfaz | Streamlit (Python) | Formularios, tablas y gráficas |
| Conexión | Janus (`janus-swi`) | Permite a Python consultar a Prolog |
| Almacenamiento | Archivos de hechos de Prolog | Guardan los datos entre sesiones |

La interfaz solo muestra información y recoge datos. Todo cálculo y toda decisión se hacen en Prolog.

## 4. Conceptos de programación declarativa que se aplican

- Hechos y reglas.
- Consultas y backtracking.
- Listas y recursión.
- Aritmética y comparaciones.
- Negación.
- Predicados de segundo orden: `findall`, `bagof`, `setof`.
- Metaprogramación: `assert` y `retract` para cambiar la configuración y las reglas mientras el programa corre.
- Entrada y salida con archivos.

## 5. Estructura del proyecto

```
gestor-gastos/
├── README.md
├── requirements.txt
├── .gitignore
├── app/                      # Interfaz en Streamlit
│   ├── main.py               # Página principal
│   ├── puente_prolog.py      # Llamadas a Prolog con Janus
│   └── pages/                # Una página por pantalla
│       ├── 1_Registro.py
│       ├── 2_Historial.py
│       ├── 3_Informe.py
│       ├── 4_Reglas.py
│       └── 5_Plan_de_ahorro.py
├── prolog/                   # Toda la lógica
│   ├── main.pl               # Carga todos los módulos
│   ├── datos.pl              # Hechos dinámicos, guardar y cargar
│   ├── calculos.pl           # Totales, porcentajes, día de mayor gasto
│   ├── comparacion.pl        # Comparación con el mes anterior
│   ├── alertas.pl            # Alertas
│   ├── reglas.pl             # Reglas configurables del usuario
│   └── plan_ahorro.pl        # Planificador de metas de ahorro
├── datos/                    # Datos guardados por la aplicación
├── tests/                    # Pruebas de la lógica (plunit)
│   └── pruebas.pl
└── docs/                     # Propuesta e informe
    └── propuesta.md
```

## 6. Instalación

Requisitos:
- SWI-Prolog 9 o superior (swi-prolog.org).
- Python 3.10 o superior.

Pasos:

```bash
pip install -r requirements.txt
```

El archivo `requirements.txt` incluye `streamlit` y `janus-swi`.

## 7. Cómo ejecutar

```bash
streamlit run app/main.py
```

Para probar solo la lógica en Prolog:

```bash
swipl prolog/main.pl
```

## 8. Estado del proyecto

- [ ] Instalación y prueba de conexión Python con Prolog
- [ ] Hechos básicos y guardado de datos
- [ ] Totales, porcentajes y filtros
- [ ] Comparación con el mes anterior y día de mayor gasto
- [ ] Alertas
- [ ] Reglas configurables
- [ ] Planificador de metas de ahorro
- [ ] Interfaz en Streamlit
- [ ] Pruebas
- [ ] Informe final y exposición

## 9. Plan de trabajo

| Semana | Actividad |
|---|---|
| 1 | Entorno, prueba de conexión y hechos básicos |
| 2 | Totales, porcentajes, filtros e interfaz mínima |
| 3 | Comparación con el mes anterior, día de mayor gasto y alertas |
| 4 | Reglas configurables y guardado en archivo |
| 5 | Planificador de metas de ahorro |
| 6 | Interfaz completa, pruebas, informe y exposición |

## 10. Alcance

- Una sola persona usuaria.
- Datos guardados en archivos locales.
- Sin cuentas de usuario, conexión a bancos ni conversión de monedas.
- Las reglas configurables son de tipos predefinidos con parámetros que elige el usuario.
