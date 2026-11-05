defmodule Depuracion do
  @moduledoc """
  Depura la lista de conexiones antes de construir el grafo, usando solo
  recursión propia (sin Enum ni Stream):
  - descarta las conexiones de una ciudad consigo misma;
  - descarta las repetidas (mismo sentido o sentido contrario);
  - si un par aparece con otra distancia, conserva la primera.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def depurar(conexiones), do: depurar(conexiones, [], [])

  defp depurar([], conservadas, descartes) do
    {invertir(conservadas, []), invertir(descartes, [])}
  end

  defp depurar(
         [{numero, linea, %Conexion{origen: ciudad, destino: ciudad}} | resto],
         conservadas,
         descartes
       ) do
    motivo = "conecta una ciudad consigo misma; se descarta"
    depurar(resto, conservadas, [{numero, linea, motivo} | descartes])
  end

  defp depurar([{numero, linea, conexion} = actual | resto], conservadas, descartes) do
    case buscar_par(conservadas, conexion) do
      nil ->
        depurar(resto, [actual | conservadas], descartes)

      {numero_previo, _linea_previa, previa} ->
        motivo = motivo_duplicado(conexion, previa, numero_previo)
        depurar(resto, conservadas, [{numero, linea, motivo} | descartes])
    end
  end

  defp buscar_par([], _conexion), do: nil

  defp buscar_par([{_numero, _linea, previa} = item | resto], conexion) do
    if mismo_par?(previa, conexion) do
      item
    else
      buscar_par(resto, conexion)
    end
  end

  defp mismo_par?(a, b) do
    (a.origen == b.origen and a.destino == b.destino) or
      (a.origen == b.destino and a.destino == b.origen)
  end

  defp motivo_duplicado(conexion, previa, numero_previo) do
    if conexion.distancia == previa.distancia do
      "repetida (línea #{numero_previo}); se descarta"
    else
      "distancia distinta a la de la línea #{numero_previo} (#{previa.distancia}); " <>
        "se conserva la de la línea #{numero_previo}"
    end
  end

  defp invertir([], acumulado), do: acumulado
  defp invertir([cabeza | cola], acumulado), do: invertir(cola, [cabeza | acumulado])
end
