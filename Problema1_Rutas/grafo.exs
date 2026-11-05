defmodule Grafo do
  @moduledoc """
  Construye el grafo de ciudades a partir de las conexiones depuradas.
  El grafo es un mapa: ciudad => [{vecino, distancia}].
  Las conexiones se pueden recorrer en ambos sentidos.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  # Recibe [{numero, linea, %Conexion{}}] y devuelve el mapa de vecinos
  def construir(conexiones) do
    Enum.reduce(conexiones, %{}, fn {_numero, _linea, conexion}, grafo ->     # (1) ¿con qué empieza el grafo?
      grafo
      |> agregar_vecino(conexion.origen, conexion.destino, conexion.distancia)
      |> agregar_vecino(conexion.destino, conexion.origen, conexion.distancia)                         # (2) el sentido contrario
    end)
  end

  # Ciudades a las que se puede ir desde `ciudad`
  def vecinos(grafo, ciudad), do: Map.get(grafo, ciudad, [])                 # (3) si la ciudad no tiene vecinos

  # ¿La ciudad aparece en el grafo?
  def existe?(grafo, ciudad), do: Map.has_key?(grafo, ciudad)

  # Agrega `vecino` a la lista de `ciudad`, al final para conservar el orden
  defp agregar_vecino(grafo, ciudad, vecino, distancia) do
    Map.update(grafo, ciudad, [{vecino, distancia}], fn vecinos ->
      vecinos ++ [{vecino, distancia}]                                                          # (4) ¿qué se agrega al final?
    end)
  end
end
