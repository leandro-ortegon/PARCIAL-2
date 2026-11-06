defmodule Salida do
  @moduledoc """
  Escribe resultados en archivos línea por línea y los muestra en pantalla.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def escribir_lineas(lineas, ruta) do
    lineas
    |> Stream.map(fn linea -> linea <> "\n" end)
    |> Enum.into(File.stream!(ruta, [:write]))

    :ok
  end

  def mostrar_lineas(lineas), do: Enum.each(lineas, &IO.puts/1)
end
