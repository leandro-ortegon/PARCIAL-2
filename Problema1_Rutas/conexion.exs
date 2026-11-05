defmodule Conexion do
  @moduledoc """
  Representa una conexión entre dos ciudades y su distancia en kilómetros.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  @enforce_keys [:origen, :destino, :distancia]
  defstruct [:origen, :destino, :distancia]

  def parse(linea) do
    campos =
      linea
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    case campos do
      [origen, destino, distancia] ->
        convertir_distancia(origen, destino, distancia)

      _ ->
        {:error, "campos faltantes"}
    end
  end

  defp convertir_distancia(origen, destino, texto) do
    case Integer.parse(texto) do
      {distancia, ""} ->
        {:ok, %Conexion{origen: origen, destino: destino, distancia: distancia}}

      _ ->
        {:error, "distancia no numerica"}
    end
  end
end
