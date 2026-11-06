defmodule Validacion do
  @moduledoc """
  Valida el mapa de la isla antes de buscar rutas, usando solo recursión
  propia (sin Enum ni Stream):
  - todas las filas tienen el mismo número de posiciones;
  - todos los símbolos aparecen en terrenos.csv;
  - hay exactamente una posición inicial P y exactamente un bote B;
  - todo el borde del mapa es agua (~).
  Devuelve :ok o {:error, problemas} con TODOS los problemas encontrados.
  - Autor: César Leandro Ortegón
  - Fecha: Noviembre 2026
  """

  def validar(filas, terrenos) do
    total = length(filas)
    ancho = ancho_esperado(filas)

    problemas = revisar_anchos(filas, 0, ancho, [])
    problemas = revisar_filas(filas, 0, total, terrenos, problemas)
    problemas = revisar_cantidad(posiciones_de(filas, "P", 0, []), "posiciones iniciales P", "No hay posición inicial P", problemas)
    problemas = revisar_cantidad(posiciones_de(filas, "B", 0, []), "botes B", "No hay bote B", problemas)

    case invertir(problemas, []) do
      [] -> :ok
      lista -> {:error, lista}
    end
  end

  defp ancho_esperado([]), do: 0
  defp ancho_esperado([primera | _resto]), do: length(primera)

  defp revisar_anchos([], _f, _ancho, problemas), do: problemas

  defp revisar_anchos([fila | resto], f, ancho, problemas) do
    if length(fila) == ancho do
      revisar_anchos(resto, f + 1, ancho, problemas)
    else
      problema = "Fila #{f}: tiene #{length(fila)} posiciones; se esperaban #{ancho}"
      revisar_anchos(resto, f + 1, ancho, [problema | problemas])
    end
  end

  defp revisar_filas([], _f, _total, _terrenos, problemas), do: problemas

  defp revisar_filas([fila | resto], f, total, terrenos, problemas) do
    problemas = revisar_columnas(fila, f, 0, length(fila) - 1, total, terrenos, problemas)
    revisar_filas(resto, f + 1, total, terrenos, problemas)
  end

  defp revisar_columnas([], _f, _c, _ultima, _total, _terrenos, problemas), do: problemas

  defp revisar_columnas([simbolo | resto], f, c, ultima, total, terrenos, problemas) do
    problemas = revisar_simbolo(simbolo, f, c, terrenos, problemas)
    problemas = revisar_borde(simbolo, f, c, ultima, total, problemas)
    revisar_columnas(resto, f, c + 1, ultima, total, terrenos, problemas)
  end

  defp revisar_simbolo(simbolo, f, c, terrenos, problemas) do
    if Map.has_key?(terrenos, simbolo) do
      problemas
    else
      ["Posición #{posicion(f, c)}: el símbolo #{simbolo} no está en terrenos.csv" | problemas]
    end
  end

  defp revisar_borde("~", _f, _c, _ultima, _total, problemas), do: problemas

  defp revisar_borde(simbolo, f, c, ultima, total, problemas) do
    if f == 0 or f == total - 1 or c == 0 or c == ultima do
      ["Posición #{posicion(f, c)}: el borde debe ser agua y contiene #{simbolo}" | problemas]
    else
      problemas
    end
  end

  defp posiciones_de([], _simbolo, _f, encontradas), do: invertir(encontradas, [])

  defp posiciones_de([fila | resto], simbolo, f, encontradas) do
    posiciones_de(resto, simbolo, f + 1, buscar_en_fila(fila, simbolo, f, 0, encontradas))
  end

  defp buscar_en_fila([], _simbolo, _f, _c, encontradas), do: encontradas

  defp buscar_en_fila([simbolo | resto], simbolo, f, c, encontradas) do
    buscar_en_fila(resto, simbolo, f, c + 1, [{f, c} | encontradas])
  end

  defp buscar_en_fila([_otro | resto], simbolo, f, c, encontradas) do
    buscar_en_fila(resto, simbolo, f, c + 1, encontradas)
  end

  defp revisar_cantidad([_una], _plural, _faltante, problemas), do: problemas
  defp revisar_cantidad([], _plural, faltante, problemas), do: [faltante | problemas]

  defp revisar_cantidad(varias, plural, _faltante, problemas) do
    ["Hay #{length(varias)} #{plural}: #{unir(varias)}" | problemas]
  end

  defp unir([{f, c}]), do: posicion(f, c)
  defp unir([{f1, c1}, {f2, c2}]), do: posicion(f1, c1) <> " y " <> posicion(f2, c2)
  defp unir([{f, c} | resto]), do: posicion(f, c) <> ", " <> unir(resto)

  defp posicion(f, c), do: "{#{f},#{c}}"

  defp invertir([], acumulado), do: acumulado
  defp invertir([cabeza | cola], acumulado), do: invertir(cola, [cabeza | acumulado])
end
