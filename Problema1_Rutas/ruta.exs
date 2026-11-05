defmodule Ruta do
  @moduledoc """
  Representa una ruta encontrada: la lista de ciudades en orden
  y la distancia total en kilómetros.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  @enforce_keys [:ciudades, :distancia]
  defstruct [:ciudades, :distancia]

  def numero_ciudades(%Ruta{ciudades: ciudades}), do: length(ciudades)

  def recorrido(%Ruta{ciudades: ciudades}), do: Enum.join(ciudades, " -> ")

  def a_texto(%Ruta{} = ruta) do
    "#{recorrido(ruta)} (#{numero_ciudades(ruta)} ciudades, #{ruta.distancia} km)"
  end
end
