defmodule Lector do
  @moduledoc """
  Lee los archivos de entrada de forma perezosa, línea por línea.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def leer_conexiones(ruta), do: leer(ruta, &Conexion.parse/1)

  def leer_consultas(ruta), do: leer(ruta, &parse_consulta/1)

  defp leer(ruta, convertir) do
    if File.exists?(ruta) do
      {validas, errores} =
        ruta
        |> File.stream!()
        |> Stream.with_index(1)
        |> Stream.map(fn {linea, numero} -> {numero, String.trim(linea)} end)
        |> Stream.reject(fn {_numero, linea} -> ignorar?(linea) end)
        |> Stream.map(fn {numero, linea} -> {numero, linea, convertir.(linea)} end)
        |> Enum.reduce({[], []}, &clasificar/2)

      {:ok, Enum.reverse(validas), Enum.reverse(errores)}
    else
      {:error, "El archivo #{ruta} no existe"}
    end
  end

  defp parse_consulta(linea) do
    case linea |> String.split(",") |> Enum.map(&String.trim/1) do
      [origen, destino] when origen != "" and destino != "" -> {:ok, {origen, destino}}
      _ -> {:error, "consulta mal formada"}
    end
  end

  defp ignorar?(""), do: true
  defp ignorar?(linea), do: String.starts_with?(linea, "#")

  defp clasificar({numero, linea, {:ok, dato}}, {validas, errores}) do
    {[{numero, linea, dato} | validas], errores}
  end

  defp clasificar({numero, linea, {:error, motivo}}, {validas, errores}) do
    {validas, [{numero, linea, motivo} | errores]}
  end
end
