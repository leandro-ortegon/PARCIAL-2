defmodule Alcance do
  @moduledoc """
  Calcula, con un Stream infinito, los conjuntos de ciudades alcanzables
  desde un origen. El paso 0 contiene solo el origen y cada paso agrega los
  vecinos de las ciudades del paso anterior. Se detiene en el primer paso repetido.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def secuencia(grafo, origen) do
    Stream.iterate([origen], fn conjunto -> siguiente_paso(grafo, conjunto) end)
  end

  def pasos(grafo, origen) do
    pares_distintos =
      secuencia(grafo, origen)
      |> Stream.chunk_every(2, 1)
      |> Stream.take_while(fn [anterior, actual] -> anterior != actual end)
      |> Enum.to_list()

    [[origen] | Enum.map(pares_distintos, fn [_anterior, actual] -> actual end)]
  end

  def alcanzable?(pasos, destino), do: destino in List.last(pasos)

  defp siguiente_paso(grafo, conjunto) do
    vecinos =
      Enum.flat_map(conjunto, fn ciudad ->
        Enum.map(Grafo.vecinos(grafo, ciudad), fn {vecino, _distancia} -> vecino end)
      end)

    (conjunto ++ vecinos)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
