defmodule Programa do
  @moduledoc """
  Problema 1: rutas entre ciudades. Orquesta la lectura, la depuración,
  el grafo, el alcance, la búsqueda y la escritura de resultados.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  @entradas Path.join(__DIR__, "entradas")
  @salidas Path.join(__DIR__, "salidas")

  def main do
    with {:ok, validas, errores} <- Lector.leer_conexiones(Path.join(@entradas, "conexiones.csv")),
         {:ok, consultas, errores_consultas} <- Lector.leer_consultas(Path.join(@entradas, "consultas.txt")) do
      File.mkdir_p!(@salidas)

      {conservadas, descartes} = Depuracion.depurar(validas)
      grafo = Grafo.construir(conservadas)

      resultados =
        Enum.map(consultas, fn {_numero, _linea, {origen, destino}} ->
          resolver(grafo, origen, destino)
        end)

      publicar(Reporte.lineas_errores(errores), "errores_conexiones.txt")
      publicar(Reporte.lineas_errores(descartes), "depuracion_conexiones.txt")
      publicar(Stream.flat_map(resultados, &Reporte.lineas_alcance/1), "alcance.txt")
      publicar(Stream.flat_map(resultados, &Reporte.lineas_consulta/1), "rutas_encontradas.txt")
      mostrar_errores_consultas(errores_consultas)
    else
      {:error, mensaje} -> IO.puts(:standard_error, mensaje)
    end
  end

  defp resolver(grafo, origen, destino) do
    faltantes = [origen, destino] |> Enum.uniq() |> Enum.reject(&Grafo.existe?(grafo, &1))

    if faltantes != [] do
      %{origen: origen, destino: destino, estado: :ciudad_inexistente, faltantes: faltantes, pasos: nil}
    else
      pasos = Alcance.pasos(grafo, origen)

      if Alcance.alcanzable?(pasos, destino) do
        rutas = Busqueda.rutas(grafo, origen, destino)
        %{origen: origen, destino: destino, estado: :con_rutas, pasos: pasos, rutas: rutas}
      else
        %{origen: origen, destino: destino, estado: :sin_rutas, pasos: pasos}
      end
    end
  end

  defp publicar(lineas, nombre) do
    Salida.escribir_lineas(lineas, Path.join(@salidas, nombre))
    IO.puts("\n----- #{nombre} -----")

    if Enum.empty?(lineas) do
      IO.puts("(sin registros)")
    else
      Salida.mostrar_lineas(lineas)
    end
  end

  defp mostrar_errores_consultas([]), do: :ok

  defp mostrar_errores_consultas(errores) do
    IO.puts("\n----- consultas ignoradas -----")
    errores |> Reporte.lineas_errores() |> Salida.mostrar_lineas()
  end
end

Programa.main()
