defmodule Programa do
  @moduledoc """
  Problema 2: escapar de la isla. Orquesta la lectura, la validación del
  mapa, la búsqueda de rutas y la escritura de resultados.
  Uso: elixir -r ... programa.exs [archivo_isla]   (por defecto isla.txt)
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  @entradas Path.join(__DIR__, "entradas")
  @salidas Path.join(__DIR__, "salidas")

  def main(argumentos) do
    archivo_isla = archivo_isla(argumentos)

    with {:ok, terrenos, errores_terrenos} <- Lector.leer_terrenos(Path.join(@entradas, "terrenos.csv")),
         {:ok, filas} <- Lector.leer_isla(Path.join(@entradas, archivo_isla)) do
      File.mkdir_p!(@salidas)
      mostrar_errores_terrenos(errores_terrenos)

      case Validacion.validar(filas, terrenos) do
        :ok ->
          publicar(["El mapa es válido"], "validacion_isla.txt")
          resolver(filas, terrenos)

        {:error, problemas} ->
          publicar(problemas, "validacion_isla.txt")
          IO.puts("\nEl mapa no es válido: no se buscan rutas.")
      end
    else
      {:error, mensaje} -> IO.puts(:standard_error, mensaje)
    end
  end

  defp archivo_isla([]), do: "isla.txt"
  defp archivo_isla([archivo | _resto]), do: archivo

  defp resolver(filas, terrenos) do
    mapa = Mapa.construir(filas, terrenos)
    rutas = Busqueda.rutas(mapa, Mapa.buscar(mapa, "P"), Mapa.buscar(mapa, "B"))

    IO.puts("\n----- rutas encontradas -----")
    Salida.mostrar_lineas(Reporte.lineas_rutas(rutas))

    Salida.escribir_lineas(Reporte.lineas_csv(rutas), Path.join(@salidas, "rutas_isla.csv"))
    IO.puts("Archivo generado: salidas/rutas_isla.csv")

    publicar(Reporte.lineas_resumen(rutas, filas), "resumen_isla.txt")
  end

  defp publicar(lineas, nombre) do
    Salida.escribir_lineas(lineas, Path.join(@salidas, nombre))
    IO.puts("\n----- #{nombre} -----")
    Salida.mostrar_lineas(lineas)
  end

  defp mostrar_errores_terrenos([]), do: :ok

  defp mostrar_errores_terrenos(errores) do
    IO.puts("----- líneas ignoradas de terrenos.csv -----")
    Enum.each(errores, fn {numero, linea, motivo} -> IO.puts("Línea #{numero}: #{linea} -> #{motivo}") end)
  end
end

Programa.main(System.argv())
