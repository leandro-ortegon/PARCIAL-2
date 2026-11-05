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

  # Recibe [{numero, linea, %Conexion{}}] y devuelve {conservadas, descartes}
  # descartes: [{numero, linea, motivo}]
  def depurar(conexiones), do: depurar(conexiones, [], [])

  # (1) CASO BASE: ya no quedan conexiones por revisar
  defp depurar([], conservadas, descartes) do
    {invertir(conservadas, []), invertir(descartes, [])}
  end

  # (2) Ciudad consigo misma: origen y destino son la MISMA variable
  defp depurar([{numero, linea, %Conexion{origen: ciudad, destino: ciudad}} | resto], conservadas, descartes) do
    motivo = "conecta una ciudad consigo misma; se descarta"
    depurar(resto, conservadas, [{numero, linea, motivo} | descartes])
  end

  # Caso general: buscar si el par ya fue conservado
  defp depurar([{numero, linea, conexion} = actual | resto], conservadas, descartes) do
    case buscar_par(conservadas, conexion) do
      nil ->
        # (3) Par nuevo: se conserva
        depurar(resto, [actual | conservadas], descartes)

      {numero_previo, _linea_previa, previa} ->
        motivo = motivo_duplicado(conexion, previa, numero_previo)
        # (4) Par repetido: se descarta
        depurar(resto, conservadas, [{numero, linea, motivo} | descartes])
    end
  end

  # Busca en las conservadas una conexión con el mismo par de ciudades
  # (5) CASO BASE: se recorrió todo y no se encontró
  defp buscar_par([], _conexion), do: nil

  defp buscar_par([{_numero, _linea, previa} = item | resto], conexion) do
    if mismo_par?(previa, conexion) do
      item
    else
      # (6) Seguir buscando en el resto
      buscar_par(resto, conexion)
    end
  end

  # Mismo par en el mismo sentido o en el sentido contrario
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

  # Invierte una lista con recursión de cola (reemplaza a Enum.reverse)
  defp invertir([], acumulado), do: acumulado
  defp invertir([cabeza | cola], acumulado), do: invertir(cola, [cabeza | acumulado])
end
