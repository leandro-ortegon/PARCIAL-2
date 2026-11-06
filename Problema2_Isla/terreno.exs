defmodule Terreno do
  @moduledoc """
  Representa un tipo de terreno de la isla: su símbolo, nombre, si se puede
  transitar y el costo de entrar a una posición de ese tipo.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  @enforce_keys [:simbolo, :nombre, :transitable, :costo]
  defstruct [:simbolo, :nombre, :transitable, :costo]

  def parse(linea) do
    campos =
      linea
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    case campos do
      [simbolo, nombre, transitable, costo] ->
        convertir(simbolo, nombre, transitable, costo)

      _ ->
        {:error, "campos faltantes"}
    end
  end

  defp convertir(simbolo, nombre, transitable, costo) do
    with {:ok, es_transitable} <- convertir_transitable(transitable),
         {valor, ""} <- Integer.parse(costo) do
      {:ok, %Terreno{simbolo: simbolo, nombre: nombre, transitable: es_transitable, costo: valor}}
    else
      {:error, motivo} -> {:error, motivo}
      _ -> {:error, "costo no numérico"}
    end
  end

  defp convertir_transitable("si"), do: {:ok, true}
  defp convertir_transitable("no"), do: {:ok, false}
  defp convertir_transitable(_), do: {:error, "transitable debe ser si o no"}
end
