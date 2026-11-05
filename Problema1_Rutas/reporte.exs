defmodule Reporte do
  @moduledoc """
  Construye las líneas de texto de cada archivo de salida. No escribe ni
  imprime nada: solo transforma datos en texto.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def lineas_errores(errores) do
    Enum.map(errores, fn {numero, linea, motivo} -> "Línea #{numero}: #{linea} -> #{motivo}" end)
  end

  def lineas_alcance(%{origen: origen, pasos: nil}) do
    ["=== Alcance desde #{origen} ===", "No se calcula: la consulta tiene ciudades que no existen", ""]
  end

  def lineas_alcance(%{origen: origen, pasos: pasos}) do
    detalle =
      pasos
      |> Enum.with_index()
      |> Enum.map(fn {paso, numero} -> "Paso #{numero}: #{Enum.join(paso, ", ")}" end)

    ["=== Alcance desde #{origen} ==="] ++
      detalle ++ ["Se estabiliza en el paso #{length(pasos) - 1}", ""]
  end

  def lineas_consulta(%{origen: origen, destino: destino} = resultado) do
    ["=== #{origen} -> #{destino} ==="] ++ detalle(resultado) ++ [""]
  end

  def mas_cortas(rutas) do
    minimo = rutas |> Enum.map(&Ruta.numero_ciudades/1) |> Enum.min()
    Enum.filter(rutas, fn ruta -> Ruta.numero_ciudades(ruta) == minimo end)
  end

  def menor_distancia(rutas), do: Enum.min_by(rutas, fn ruta -> ruta.distancia end)

  defp detalle(%{estado: :ciudad_inexistente, faltantes: faltantes}) do
    ["No existe en el grafo: #{Enum.join(faltantes, ", ")}"]
  end

  defp detalle(%{estado: :sin_rutas}) do
    ["Sin rutas: el destino no es alcanzable desde el origen", "Número de rutas: 0"]
  end

  defp detalle(%{estado: :con_rutas, rutas: rutas}) do
    numeradas =
      rutas
      |> Enum.with_index(1)
      |> Enum.map(fn {ruta, numero} -> "Ruta #{numero}: #{Ruta.a_texto(ruta)}" end)

    cortas = rutas |> mas_cortas() |> Enum.map(&Ruta.recorrido/1) |> Enum.join(" | ")
    menor = menor_distancia(rutas)

    numeradas ++
      [
        "Número de rutas: #{length(rutas)}",
        "Ruta más corta: #{cortas}",
        "Ruta de menor distancia: #{Ruta.recorrido(menor)} (#{menor.distancia} km)"
      ]
  end
end
