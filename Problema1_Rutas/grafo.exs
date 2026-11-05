defmodule Grafo do
  @moduledoc """
  Construye el grafo de ciudades a partir de las conexiones depuradas.
  El grafo es un mapa: ciudad => [{vecino, distancia}].
  Las conexiones se pueden recorrer en ambos sentidos.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def construir(conexiones) do
    Enum.reduce(conexiones, %{}, fn {_numero, _linea, conexion}, grafo ->
      grafo
      |> agregar_vecino(conexion.origen, conexion.destino, conexion.distancia)
      |> agregar_vecino(conexion.destino, conexion.origen, conexion.distancia)
    end)
  end

  def vecinos(grafo, ciudad), do: Map.get(grafo, ciudad, [])

  def existe?(grafo, ciudad), do: Map.has_key?(grafo, ciudad)

  defp agregar_vecino(grafo, ciudad, vecino, distancia) do
    Map.update(grafo, ciudad, [{vecino, distancia}], fn vecinos ->
      vecinos ++ [{vecino, distancia}]
    end)
  end
end
