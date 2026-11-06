defmodule Mapa do
  @moduledoc """
  Representa la isla como un mapa {fila, columna} => %Terreno{}, ubica
  símbolos y calcula las posiciones vecinas (arriba, abajo, izquierda, derecha).
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def construir(filas, terrenos) do
    filas
    |> Enum.with_index()
    |> Enum.flat_map(fn {fila, f} ->
      fila
      |> Enum.with_index()
      |> Enum.map(fn {simbolo, c} -> {{f, c}, Map.get(terrenos, simbolo)} end)
    end)
    |> Map.new()
  end

  def buscar(mapa, simbolo) do
    {posicion, _terreno} = Enum.find(mapa, fn {_posicion, terreno} -> terreno.simbolo == simbolo end)
    posicion
  end

  def terreno_en(mapa, posicion), do: Map.get(mapa, posicion)

  def vecinos({f, c}) do
    [
      {f - 1, c},
      {f + 1, c},
      {f, c - 1},
      {f, c + 1}
    ]
  end
end
