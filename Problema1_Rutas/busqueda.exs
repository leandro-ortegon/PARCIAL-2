defmodule Busqueda do
  @moduledoc """
  Encuentra todas las rutas entre dos ciudades con recursión y backtracking.
  Una ciudad no puede aparecer dos veces en la misma ruta.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def rutas(grafo, origen, destino), do: buscar(grafo, origen, destino, [origen], 0)

  defp buscar(_grafo, destino, destino, camino, distancia) do
    [%Ruta{ciudades: camino, distancia: distancia}]
  end

  defp buscar(grafo, actual, destino, camino, distancia) do
    explorar(Grafo.vecinos(grafo, actual), grafo, destino, camino, distancia)
  end

  defp explorar([], _grafo, _destino, _camino, _distancia), do: []

  defp explorar([{vecino, km} | resto], grafo, destino, camino, distancia) do
    rutas_por_vecino =
      if vecino in camino do
        []
      else
        buscar(grafo, vecino, destino, camino ++ [vecino], distancia + km)
      end

    rutas_por_vecino ++ explorar(resto, grafo, destino, camino, distancia)
  end
end
