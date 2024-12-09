defmodule D08Test do
  require Integer
  use ExUnit.Case

  def read_antennas do
    {:ok, content} = File.read("./test/08.txt")

    # content = """
    # ............
    # ........0...
    # .....0......
    # .......0....
    # ....0.......
    # ......A.....
    # ............
    # ............
    # ........A...
    # .........A..
    # ............
    # ............
    # """

    # content = """
    # T.........
    # ..........
    # T.........
    # ..........
    # ..........
    # ..........
    # ..........
    # ..........
    # ..........
    # ..........
    # """

    w = content |> String.split("\n", trim: true) |> hd() |> String.length()
    h = content |> String.split("\n", trim: true) |> Enum.count()

    {content
     |> String.split("\n", trim: true)
     |> Enum.reduce({0, %{}}, fn line, {row, antennas} ->
       {row + 1,
        String.split(line, "", trim: true)
        |> Enum.reduce({0, antennas}, fn cell, {col, antennas} ->
          case cell do
            "." -> {col + 1, antennas}
            _ -> {col + 1, Map.put(antennas, cell, [{col, row} | Map.get(antennas, cell, [])])}
          end
        end)
        |> elem(1)}
     end)
     |> elem(1), w, h}
  end

  def cartesian_combos([]), do: [[]]

  def cartesian_combos([head | tail]) do
    for h <- head, t <- cartesian_combos(tail), do: [h | t]
  end

  def combinations(n, list) do
    Enum.map(1..n, fn _ -> list end)
    |> cartesian_combos()
  end

  defp antiv({x1, y1}, {x2, y2}) do
    {x1 + (x1 - x2), y1 + (y1 - y2)}
  end

  defp antiv_until_oob(n1, n2, w, h, acc) do
    {x, y} = anti = antiv(n1, n2)

    if x >= 0 and x < w and y >= 0 and y < h do
      antiv_until_oob(anti, n1, w, h, [anti | acc])
    else
      acc
    end
  end

  defp part1_time({antennas, w, h}) do
    antennas
    |> Enum.reduce(%{}, fn {name, coords}, acc ->
      combinations(2, coords)
      |> Enum.filter(fn [a, b] -> a != b end)
      |> Enum.reduce(acc, fn [a, b], acc ->
        Map.put(acc, name, Map.get(acc, name, MapSet.new()) |> MapSet.put(antiv(a, b)))
      end)
    end)
    |> Enum.reduce(MapSet.new(), fn {_name, ms}, acc ->
      MapSet.union(acc, ms)
    end)
    |> MapSet.to_list()
    |> Enum.filter(fn {x, y} -> x >= 0 and x < w and y >= 0 and y < h end)
    |> Enum.count()
  end

  defp part1({antennas, w, h}) do
    {time, count} = :timer.tc(&part1_time/1, [{antennas, w, h}])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp part2_time({antennas, w, h}) do
    antennas
    |> Enum.reduce(%{}, fn {name, coords}, acc ->
      combinations(2, coords)
      |> Enum.filter(fn [a, b] -> a != b end)
      |> Enum.reduce(acc, fn [a, b], acc ->
        Map.put(
          acc,
          name,
          Map.get(acc, name, MapSet.new(coords))
          |> MapSet.union(MapSet.new(antiv_until_oob(a, b, w, h, [])))
        )
      end)
    end)
    |> Enum.reduce(MapSet.new(), fn {_name, ms}, acc ->
      MapSet.union(acc, ms)
    end)
    |> MapSet.to_list()
    |> Enum.filter(fn {x, y} -> x >= 0 and x < w and y >= 0 and y < h end)
    |> Enum.count()
  end

  defp part2({antennas, w, h}) do
    {time, count} = :timer.tc(&part2_time/1, [{antennas, w, h}])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  test "Day 8" do
    IO.puts("Day 8")
    {antennas, w, h} = read_antennas()

    part1({antennas, w, h})
    part2({antennas, w, h})
  end
end
