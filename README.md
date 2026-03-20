# Superstore Sales Pipeline

Mini pipeline SQL reproducible con MySQL 8
Proyecto de análisis de datos · 2025

---

## 1. Dataset elegido

Se utiliza el dataset **Superstore Sales**, disponible públicamente en Kaggle (Sample Superstore). Contiene información de pedidos de una tienda ficticia de suministros de oficina en Estados Unidos con datos de ventas, clientes, productos y envíos.

### Características

| Característica | Detalle                                                     |
| -------------- | ----------------------------------------------------------- |
| Filas aprox.   | 9.994 líneas de pedido                                      |
| Período        | 2014 – 2017                                                 |
| Fuente         | Kaggle — Sample Superstore Dataset                          |
| Campos clave   | Order ID, Customer ID, Product ID, Sales, Ship Mode, Region |
| Archivo        | `data/superstore.csv`                                       |

---

## 2. Preguntas de negocio

El pipeline responde las siguientes 10 preguntas analíticas:

1. ¿Cuáles son las ventas y el margen de beneficio por región?
2. ¿Quiénes son los 10 clientes con mayor gasto total?
3. ¿Cómo evolucionan las ventas mensualmente y cuál es la variación respecto al mes anterior?
4. ¿Qué categoría y subcategoría genera más beneficio?
5. ¿Cuál es el tiempo medio de envío por modalidad (Ship Mode)?
6. ¿Qué segmento de cliente genera más ingresos?
7. ¿Cuáles son los 5 productos más vendidos por categoría?
8. ¿Existen clientes registrados en varias regiones?
9. ¿Cuál es el acumulado de ventas por región a lo largo del tiempo?
10. ¿Qué porcentaje de pedidos aplica descuento?

---

## 3. Motor SQL utilizado

**Motor:** MySQL 8.0+

Se eligió MySQL 8 por su soporte de SQL avanzado:

- Window functions
- CTEs
- Triggers
- Stored procedures
- Transacciones ACID

### Alternativa con SQLite

Si se usa SQLite:

- `STR_TO_DATE` → `DATE()` o `strftime()`
- `DATE_FORMAT` → `strftime('%Y-%m', ...)`
- No hay triggers ni procedures → mover lógica fuera de SQL

---

## 4. Estructura del proyecto

| Archivo                     | Descripción       |
| --------------------------- | ----------------- |
| data/superstore.csv         | Dataset fuente    |
| sql/01_schema.sql           | Tabla staging     |
| sql/02_load_staging.sql     | Carga CSV         |
| sql/03_transform_core.sql   | Core (dim + fact) |
| sql/04_semantic_views.sql   | Vistas            |
| sql/05_analysis_queries.sql | Consultas         |
| sql/06_quality_checks.sql   | Calidad           |
| sql/07_advanced_sql.sql     | SQL avanzado      |
| README.md                   | Documentación     |

---

## Arquitectura del pipeline

```
CSV (raw)
→ Staging (stg_*)
→ Core (dim_* / fct_*)
→ Semantic (vw_*)
→ Analysis
```

---

## 5. Supuestos y limitaciones

### Supuestos

- `sales` = importe bruto
- `quantity` = 1 (no existe en dataset)
- `profit` = estimado al 20%
- `discount`:
  - 0% ≤ 100
  - 5% ≤ 500
  - 10% > 500

### Limitaciones

- Trigger y procedures solo MySQL
- `DISTINCT` en clientes puede generar inconsistencias
- Formato fecha depende del CSV (`DD/MM/YYYY` o `MM/DD/YYYY`)

---

## 6. Instrucciones de reproducción

### Requisitos

- MySQL 8+
- Cliente SQL (Workbench, DBeaver…)
- Dataset en `data/`

---

### Pasos

1. Ejecutar `01_schema.sql`
2. Importar CSV (`02_load_staging.sql`)
3. Ejecutar `03_transform_core.sql`
4. Ejecutar `04_semantic_views.sql`
5. Ejecutar `06_quality_checks.sql`
6. Ejecutar `05_analysis_queries.sql`
7. Ejecutar `07_advanced_sql.sql`

---

### CLI

```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p superstore_pipeline < sql/03_transform_core.sql
mysql -u root -p superstore_pipeline < sql/04_semantic_views.sql
mysql -u root -p superstore_pipeline < sql/06_quality_checks.sql
mysql -u root -p superstore_pipeline < sql/05_analysis_queries.sql
mysql -u root -p superstore_pipeline < sql/07_advanced_sql.sql
```

---

## 7. Checklist de calidad de datos

| Control                    | Resultado esperado    |
| -------------------------- | --------------------- |
| Nulos en campos clave      | 0                     |
| Duplicados                 | 0                     |
| Ventas negativas           | 0                     |
| Fechas incorrectas         | 0                     |
| Registros huérfanos        | 0                     |
| Coherencia staging vs core | Igual número de filas |

---

## 8. Conclusiones analíticas

- Región **West** lidera en ventas
- Segmento **Consumer** domina en volumen
- **Technology** es la categoría más rentable
- **Standard Class** es el envío más común
- Los descuentos reducen margen en ventas altas
- Cohortes 2014 tienen mayor LTV

---

## Limitación principal

El `profit` es estimado.
Un análisis real requeriría costes reales y gastos logísticos.
