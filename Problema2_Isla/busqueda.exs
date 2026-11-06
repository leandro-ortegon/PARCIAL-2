defmodule Busqueda do
  @moduledoc """
  Encuentra todas las rutas desde la posición inicial hasta el bote con
  recursión y backtracking. Solo se mueve arriba, abajo, izquierda o derecha,
  no repite posiciones en una misma ruta y descarta con pattern matching las
  posiciones no transitables.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def rutas(mapa, inicio, bote), do: buscar(mapa, inicio, bote, [inicio], ___)

  defp buscar(_mapa, bote, bote, camino, costo) do
    [%Ruta{posiciones: camino, costo: costo}]
  end

  defp buscar(mapa, actual, bote, camino, costo) do
    explorar(Mapa.vecinos(actual), mapa, bote, camino, costo)
  end

  defp explorar([], _mapa, _bote, _camino, _costo), do: []

  defp explorar([posicion | resto], mapa, bote, camino, costo) do
    rutas_por_vecino = intentar(Mapa.terreno_en(mapa, posicion), posicion, mapa, bote, camino, costo)
    rutas_por_vecino ++ explorar(___, mapa, bote, camino, costo)
  end

  defp intentar(___, _posicion, _mapa, _bote, _camino, _costo), do: []

  defp intentar(%Terreno{transitable: ___}, _posicion, _mapa, _bote, _camino, _costo), do: []

  defp intentar(%Terreno{costo: costo_casilla}, posicion, mapa, bote, camino, costo) do
    if posicion in camino do
      []
    else
      buscar(mapa, posicion, bote, camino ++ [posicion], costo + ___)
    end
  end
end
