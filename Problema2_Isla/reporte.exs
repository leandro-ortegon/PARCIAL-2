defmodule Reporte do
  @moduledoc """
  Construye las líneas de texto de la pantalla y de los archivos de salida.
  No escribe ni imprime nada: solo transforma datos en texto.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def lineas_rutas(rutas) do
    rutas
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {ruta, numero} ->
      [
        "Ruta #{numero}:",
        Ruta.recorrido(ruta),
        "Número de movimientos: #{Ruta.movimientos(ruta)}",
        "Costo: #{ruta.costo}",
        ""
      ]
    end)
  end

  def lineas_csv(rutas) do
    filas =
      rutas
      |> Enum.with_index(1)
      |> Enum.map(fn {ruta, numero} -> Ruta.a_csv(ruta, numero) end)

    ["ruta;movimientos;costo;recorrido" | filas]
  end

  def lineas_resumen([], _filas) do
    ["Número total de rutas: 0", "No existe ninguna ruta desde la posición inicial hasta el bote"]
  end

  def lineas_resumen(rutas, filas) do
    cortas = mas_cortas(rutas)
    barata = menor_costo(rutas)

    ["Número total de rutas: #{length(rutas)}",
     "Ruta más corta: #{Ruta.movimientos(hd(cortas))} movimientos"] ++
      Enum.map(cortas, fn ruta -> "  " <> Ruta.recorrido(ruta) end) ++
      ["Ruta de menor costo: costo #{barata.costo} (#{Ruta.movimientos(barata)} movimientos)",
       "  " <> Ruta.recorrido(barata),
       "",
       "Mapa con la ruta de menor costo marcada con *:"] ++
      mapa_marcado(filas, barata)
  end

  def mas_cortas(rutas) do
    minimo = rutas |> Enum.map(&Ruta.movimientos/1) |> Enum.min()
    Enum.filter(rutas, fn ruta -> Ruta.movimientos(ruta) == minimo end)
  end

  def menor_costo(rutas), do: Enum.min_by(rutas, fn ruta -> ruta.costo end)

  def mapa_marcado(filas, %Ruta{posiciones: posiciones}) do
    recorridas = Enum.slice(posiciones, 1..-2//1)

    filas
    |> Enum.with_index()
    |> Enum.map(fn {fila, f} ->
      fila
      |> Enum.with_index()
      |> Enum.map(fn {simbolo, c} -> marcar(simbolo, {f, c} in recorridas) end)
      |> Enum.join(" ")
    end)
  end

  defp marcar(_simbolo, true), do: "*"
  defp marcar(simbolo, false), do: simbolo
end
