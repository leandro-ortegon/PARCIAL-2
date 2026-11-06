# Parcial 2 · Programación III

**Universidad del Quindío** · Ingeniería de Sistemas y Computación
**Estudiante:** César Leandro Ortegón
**Docente:** Carlos Andrés Flórez Villarraga
**Lenguaje:** Elixir 1.19 (Erlang/OTP 28)

Problemas resueltos:

1. **Rutas entre ciudades**: todas las rutas entre dos ciudades con recursión, depuración recursiva de conexiones y un Stream infinito de ciudades alcanzables.
2. **Escapar de la isla**: todas las rutas desde la posición inicial hasta el bote con recursión, validación recursiva del mapa y costos tomados de `terrenos.csv`.

---

## Estructura del repositorio

```
PARCIAL-2/
├── README.md
├── Documentacion/
│   ├── Parcial2_Documentacion.docx   documento del parcial (pruebas, árboles, bitácora de IA)
│   └── evidencias/
│       └── punto2/                   capturas de terminal del punto 2
├── Problema1_Rutas/
│   ├── entradas/
│   │   ├── conexiones.csv            conexiones ciudad_a,ciudad_b,distancia
│   │   └── consultas.txt             pares origen,destino
│   ├── salidas/                      la crea el programa en cada ejecución
│   ├── conexion.exs                  struct %Conexion{} y Conexion.parse/1
│   ├── lector.exs                    lectura perezosa con File.stream!/1
│   ├── depuracion.exs                validación con recursión propia (sin Enum ni Stream)
│   ├── grafo.exs                     mapa ciudad => [{vecino, distancia}]
│   ├── alcance.exs                   Stream infinito de ciudades alcanzables
│   ├── ruta.exs                      struct %Ruta{}
│   ├── busqueda.exs                  búsqueda recursiva con backtracking
│   ├── reporte.exs                   construcción de las líneas de salida
│   ├── salida.exs                    escritura línea por línea
│   └── programa.exs                  función main
└── Problema2_Isla/
    ├── entradas/
    │   ├── isla.txt                  mapa de la isla (símbolos separados por espacio)
    │   ├── terrenos.csv              simbolo,nombre,transitable,costo
    │   └── isla_invalida.txt         mapa con errores para probar la validación
    ├── terreno.exs                   struct %Terreno{} y Terreno.parse/1
    ├── ruta.exs                      struct %Ruta{}: movimientos, recorrido y línea CSV
    ├── lector.exs                    lectura perezosa de terrenos e isla
    ├── validacion.exs                validación del mapa con recursión propia
    ├── mapa.exs                      isla como {fila, columna} => %Terreno{} y vecinos
    ├── busqueda.exs                  búsqueda recursiva con backtracking
    ├── reporte.exs                   líneas de pantalla, CSV y resumen con mapa marcado
    ├── salida.exs                    escritura línea por línea
    ├── programa.exs                  función main (acepta el nombre del mapa como argumento)
    └── salidas/                      la crea el programa en cada ejecución
```

## Requisitos

- Elixir instalado. Verificar con `elixir --version`.

## Punto 1 · Rutas entre ciudades

### Ejecutar

Desde la carpeta `Problema1_Rutas`:

```bash
cd Problema1_Rutas
elixir -r conexion.exs -r lector.exs -r depuracion.exs -r grafo.exs -r alcance.exs -r ruta.exs -r busqueda.exs -r reporte.exs -r salida.exs programa.exs
```

Cada `-r` carga un módulo de apoyo. El orden importa: `ruta.exs` debe cargarse antes de `busqueda.exs`.

### Probar módulos por separado en iex

```bash
iex -r conexion.exs -r lector.exs -r depuracion.exs -r grafo.exs -r alcance.exs -r ruta.exs -r busqueda.exs
```

> En **Windows PowerShell** use `iex.bat` en lugar de `iex`, porque en PowerShell `iex` es un alias de `Invoke-Expression`.

```elixir
{:ok, validas, _errores} = Lector.leer_conexiones("entradas/conexiones.csv")
{conservadas, descartes} = Depuracion.depurar(validas)
grafo = Grafo.construir(conservadas)
Alcance.pasos(grafo, "Armenia")
Busqueda.rutas(grafo, "Armenia", "Manizales")
```

### Archivos de entrada

| Archivo | Formato | Ejemplo |
|---|---|---|
| `entradas/conexiones.csv` | `ciudad_a,ciudad_b,distancia` | `Armenia,Pereira,45` |
| `entradas/consultas.txt` | `origen,destino` | `Armenia,Manizales` |

En ambos archivos se ignoran las líneas vacías y las que comienzan con `#`. Las líneas 1 a 8 de `conexiones.csv` y 1 a 2 de `consultas.txt` son el ejemplo del enunciado; las siguientes son casos de prueba de errores.

### Archivos de salida (`salidas/`)

| Archivo | Contenido |
|---|---|
| `errores_conexiones.txt` | Líneas mal formadas con su número de línea y el motivo |
| `depuracion_conexiones.txt` | Conexiones descartadas por la depuración recursiva |
| `alcance.txt` | Pasos del Stream de ciudades alcanzables por consulta |
| `rutas_encontradas.txt` | Rutas de cada consulta, número de rutas, rutas más cortas y ruta de menor distancia |

Los archivos se crean en cada ejecución (si ya existen, se reemplazan) y se escriben línea por línea. La misma información se muestra en pantalla.

### Salida esperada (consulta del enunciado)

```
=== Armenia -> Manizales ===
Ruta 1: Armenia -> Pereira -> Manizales (3 ciudades, 97 km)
Ruta 2: Armenia -> Cartago -> Pereira -> Manizales (4 ciudades, 137 km)
Número de rutas: 2
Ruta más corta: Armenia -> Pereira -> Manizales
Ruta de menor distancia: Armenia -> Pereira -> Manizales (97 km)
```

### Casos de error contemplados

- Línea con campos faltantes o con distancia no numérica: se reporta y no se incorpora al grafo.
- Conexión repetida, de una ciudad consigo misma o con distancia distinta: se descarta en la depuración.
- Ciudad de una consulta que no existe en el grafo: se informa sin buscar rutas.
- Destino no alcanzable: se reporta "sin rutas" sin ejecutar la búsqueda recursiva.
- Consulta mal formada: se ignora y se informa.
- Archivo de entrada inexistente: mensaje claro, sin excepción.

## Punto 2 · Escapar de la isla

### Objetivo

Encontrar, mediante recursión, todas las rutas que permiten a una persona llegar desde su posición inicial `P` hasta el bote `B`, moviéndose solo hacia arriba, abajo, izquierda o derecha y sin repetir posiciones. Para cada ruta se calculan los movimientos y el costo, y se identifican la ruta más corta y la de menor costo. Los símbolos y costos se leen de `terrenos.csv`.

### Estado

Completo: todos los módulos están implementados y el programa se probó con el mapa del enunciado, con un mapa inválido y con un archivo inexistente.

### Procedimiento realizado

1. **Lectura con Streams** (`lector.exs`): `terrenos.csv` se convierte en un mapa `símbolo => %Terreno{}` e `isla.txt` en una lista de filas. Se ignoran líneas vacías y comentarios.
2. **Structs** (`terreno.exs`, `ruta.exs`): `transitable` se convierte de `si`/`no` a `true`/`false`; los movimientos de una ruta se calculan como `length(posiciones) - 1`.
3. **Validación recursiva** (`validacion.exs`): sin `Enum` ni `Stream`, revisa ancho de filas, símbolos definidos, una sola `P` y un solo `B`, y borde de agua; reporta todos los problemas encontrados.
4. **Representación de la isla** (`mapa.exs`): mapa `{fila, columna} => %Terreno{}`; una posición fuera de la isla devuelve `nil`.
5. **Búsqueda** (`busqueda.exs`): recursión con backtracking; las posiciones no transitables se descartan con el patrón `%Terreno{transitable: false}` y el costo suma el valor de cada posición a la que se entra (la inicial no suma).
6. **Reporte y salida** (`reporte.exs`, `salida.exs`, `programa.exs`): si el mapa es inválido se escribe `validacion_isla.txt` y no se buscan rutas; si es válido se generan `rutas_isla.csv` y `resumen_isla.txt`, con el mapa y la ruta de menor costo marcada con `*`.

### Ejecutar

Desde la carpeta `Problema2_Isla`:

```bash
cd Problema2_Isla
elixir -r terreno.exs -r lector.exs -r validacion.exs -r mapa.exs -r ruta.exs -r busqueda.exs -r reporte.exs -r salida.exs programa.exs
```

El nombre del mapa es opcional (por defecto `isla.txt`). Para probar la validación:

```bash
elixir -r terreno.exs -r lector.exs -r validacion.exs -r mapa.exs -r ruta.exs -r busqueda.exs -r reporte.exs -r salida.exs programa.exs isla_invalida.txt
```

### Archivos de salida (`salidas/`)

| Archivo | Contenido |
|---|---|
| `rutas_isla.csv` | Una línea por ruta: `ruta;movimientos;costo;recorrido` |
| `resumen_isla.txt` | Total de rutas, ruta más corta, ruta de menor costo y el mapa con esa ruta marcada con `*` |
| `validacion_isla.txt` | Problemas del mapa, o "El mapa es válido" |

### Probar en iex

Desde la carpeta `Problema2_Isla` (en PowerShell use `iex.bat`):

```bash
cd Problema2_Isla
iex -r terreno.exs -r lector.exs -r validacion.exs -r mapa.exs -r ruta.exs -r busqueda.exs
```

```elixir
{:ok, terrenos, _} = Lector.leer_terrenos("entradas/terrenos.csv")
{:ok, filas} = Lector.leer_isla("entradas/isla.txt")
Validacion.validar(filas, terrenos)
mapa = Mapa.construir(filas, terrenos)
rutas = Busqueda.rutas(mapa, Mapa.buscar(mapa, "P"), Mapa.buscar(mapa, "B"))
Enum.map(rutas, fn r -> Ruta.a_csv(r, 0) end)
```

### Resultados obtenidos

Con el mapa del enunciado (inicio `{1,1}`, bote `{5,5}`):

| Ruta | Movimientos | Costo |
|---|---|---|
| 1 | 10 | 16 |
| 2 | **8** | 14 |
| 3 | 10 | **10** |
| 4 | 12 | 12 |

- Número total de rutas: **4**
- Ruta más corta: **8 movimientos**
- Ruta de menor costo: **costo 10 (10 movimientos)**

Coincide con el resumen del enunciado: la ruta más corta no es la de menor costo.

Mapa de `resumen_isla.txt` con la ruta de menor costo:

```
~ ~ ~ ~ ~ ~ ~
~ P * * * * ~
~ R T T T * ~
~ D C T * * ~
~ R T C * T ~
~ C D C * B ~
~ ~ ~ ~ ~ ~ ~
```

Con `isla_invalida.txt`, `validacion_isla.txt` reporta los 4 problemas incluidos a propósito y no se buscan rutas:

```
Fila 3: tiene 6 posiciones; se esperaban 7
Posición {0,4}: el borde debe ser agua y contiene C
Posición {2,2}: el símbolo X no está en terrenos.csv
Hay 2 posiciones iniciales P: {1,1} y {4,3}
```

### Evidencias

| # | Evidencia | Archivo |
|---|---|---|
| 1 | Pruebas de `Terreno.parse/1` | [01_terreno_parse.png](Documentacion/evidencias/punto2/01_terreno_parse.png) |
| 2 | Pruebas de `Ruta` | [02_ruta.png](Documentacion/evidencias/punto2/02_ruta.png) |
| 3 | Lectura de terrenos, isla y archivo inexistente | [03_lector.png](Documentacion/evidencias/punto2/03_lector.png) |
| 4 | Validación del mapa del enunciado | [04_validacion.png](Documentacion/evidencias/punto2/04_validacion.png) |
| 5 | Carga de datos para la búsqueda | [05_carga_terrenos_isla.png](Documentacion/evidencias/punto2/05_carga_terrenos_isla.png) |
| 6 | `Mapa.construir/2` (inicio) | [06_mapa_construir_inicio.png](Documentacion/evidencias/punto2/06_mapa_construir_inicio.png) |
| 7 | `Mapa.construir/2` (final) | [07_mapa_construir_final.png](Documentacion/evidencias/punto2/07_mapa_construir_final.png) |
| 8 | Ubicación de `P` y `B` | [08_buscar_inicio_bote.png](Documentacion/evidencias/punto2/08_buscar_inicio_bote.png) |
| 9 | `Busqueda.rutas/3` | [09_busqueda_rutas.png](Documentacion/evidencias/punto2/09_busqueda_rutas.png) |
| 10 | Las 4 rutas en formato CSV | [10_rutas_csv.png](Documentacion/evidencias/punto2/10_rutas_csv.png) |
| 11 | Programa con mapa inválido y archivo inexistente | [11_programa_invalida_y_no_existe.png](Documentacion/evidencias/punto2/11_programa_invalida_y_no_existe.png) |

La explicación detallada, las pruebas de escritorio y los árboles de llamadas están en el capítulo 3 de [Parcial2_Documentacion.docx](Documentacion/Parcial2_Documentacion.docx).

## Tecnologías y herramientas

- **Elixir 1.19.5** sobre **Erlang/OTP 28**: `File.stream!`, `Stream`, `Enum`, `Map`, structs, pattern matching, `with` y recursión.
- **iex** para las pruebas de cada módulo y **elixir** para ejecutar los programas.
- **Visual Studio Code** y **PowerShell** en Windows.
- **Git** y **GitHub** para el control de versiones, con un commit por etapa.
- **Claude** como apoyo de aprendizaje (ver bitácoras de IA).

## Organización de evidencias

| Punto | Dónde están las evidencias |
|---|---|
| Punto 1 | Capturas incluidas en el capítulo 2 de [Parcial2_Documentacion.docx](Documentacion/Parcial2_Documentacion.docx) |
| Punto 2 | Capítulo 3 del documento y carpeta [Documentacion/evidencias/punto2](Documentacion/evidencias/punto2) |

## Documentación y uso de IA

El documento `Documentacion/Parcial2_Documentacion.docx` contiene la explicación de cada módulo, las pruebas de escritorio, los árboles de llamadas recursivas, las evidencias de ejecución y la bitácora de uso de inteligencia artificial de cada problema (sección 2.11 para el punto 1 y 3.10 para el punto 2). En este trabajo se usó Claude como apoyo; el detalle de cada interacción está registrado en ese documento.
