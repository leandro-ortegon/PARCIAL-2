defmodule Ruta do
  @moduledoc """
  Representa una ruta en la isla: la lista de posiciones {fila, columna}
  en orden y el costo total de la ruta.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  @enforce_keys [:posiciones, :costo]
  defstruct [:posiciones, :costo]

  def movimientos(%Ruta{posiciones: posiciones}), do: length(posiciones) - 1

  def posicion_texto({fila, columna}), do: "{#{fila},#{columna}}"

  def recorrido(%Ruta{posiciones: posiciones}) do
    posiciones
    |> Enum.map(&posicion_texto/1)
    |> Enum.join(" -> ")
  end

  def a_csv(%Ruta{} = ruta, numero) do
    "#{numero};#{movimientos(ruta)};#{ruta.costo};#{recorrido(ruta)}"
  end
end
