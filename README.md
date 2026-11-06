# Parcial 2 · Programación III

**Universidad del Quindío** · Ingeniería de Sistemas y Computación
**Estudiante:** César Leandro Ortegón
**Docente:** Carlos Andrés Flórez Villarraga
**Lenguaje:** Elixir 1.19 (Erlang/OTP 28)

Problemas resueltos:

1. **Rutas entre ciudades**: todas las rutas entre dos ciudades con recursión, depuración recursiva de conexiones y un Stream infinito de ciudades alcanzables.
2. **Escapar de la isla**: *(en desarrollo)*.

---

## Estructura del repositorio

```
PARCIAL-2/
├── README.md
├── Documentacion/
│   └── Parcial2_Documentacion.docx   documento del parcial (pruebas, árboles, bitácora de IA)
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
└── Problema2_Isla/                   (en desarrollo)
```

## Requisitos

- Elixir instalado. Verificar con `elixir --version`.

## Problema 1: Rutas entre ciudades

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

## Problema 2: Escapar de la isla

*En desarrollo.*

## Documentación y uso de IA

El documento `Documentacion/Parcial2_Documentacion.docx` contiene la explicación de cada módulo, las pruebas de escritorio, los árboles de llamadas recursivas, las evidencias de ejecución y la bitácora de uso de inteligencia artificial de cada problema. En este trabajo se usó Claude como apoyo; el detalle de cada interacción está registrado en ese documento.
