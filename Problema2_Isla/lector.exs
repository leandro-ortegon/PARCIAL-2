defmodule Lector do
  @moduledoc """
  Lee los archivos de entrada de la isla de forma perezosa, línea por línea.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def leer_terrenos(ruta) do
    with {:ok, validos, errores} <- leer(ruta, &Terreno.parse/1) do
      terrenos = Map.new(validos, fn {_numero, _linea, terreno} -> {terreno.simbolo, terreno} end)
      {:ok, terrenos, errores}
    end
  end

  def leer_isla(ruta) do
    with {:ok, filas, _errores} <- leer(ruta, fn linea -> {:ok, String.split(linea)} end) do
      {:ok, Enum.map(filas, fn {_numero, _linea, simbolos} -> simbolos end)}
    end
  end

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

  defp ignorar?(""), do: true
  defp ignorar?(linea), do: String.starts_with?(linea, "#")

  defp clasificar({numero, linea, {:ok, dato}}, {validas, errores}) do
    {[{numero, linea, dato} | validas], errores}
  end

  defp clasificar({numero, linea, {:error, motivo}}, {validas, errores}) do
    {validas, [{numero, linea, motivo} | errores]}
  end
end
