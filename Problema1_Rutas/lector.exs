defmodule Lector do
  @moduledoc """
  Lee los archivos de entrada de forma perezosa, línea por línea.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def leer_conexiones(ruta) do
    if File.exists?(ruta) do
      {validas, errores} =
        ruta
        |> File.stream!()
        |> Stream.with_index(1)
        |> Stream.map(fn {linea, numero} -> {numero, String.trim(linea)} end)
        |> Stream.reject(fn {_numero, linea} -> ignorar?(linea) end)
        |> Stream.map(fn {numero, linea} -> {numero, linea, Conexion.parse(linea)} end)
        |> Enum.reduce({[], []}, &clasificar/2)

      {:ok, Enum.reverse(validas), Enum.reverse(errores)}
    else
      {:error, "El archivo #{ruta} no existe"}
    end
  end

  defp ignorar?(""), do: true
  defp ignorar?(linea), do: String.starts_with?(linea, "#")

  defp clasificar({numero, linea, {:ok, conexion}}, {validas, errores}) do
    {[{numero, linea, conexion} | validas], errores}
  end

  defp clasificar({numero, linea, {:error, motivo}}, {validas, errores}) do
    {validas, [{numero, linea, motivo} | errores]}
  end
end
