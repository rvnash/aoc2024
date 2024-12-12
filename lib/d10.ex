defmodule D10 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      .....0.
      ..4321.
      ..5..2.
      ..6543.
      ..7..4.
      ..8765.
      ..9....
      """,

      # 13
      2 => """
      ..90..9
      ...1.98
      ...2..7
      6543456
      765.987
      876....
      987....
      """,

      # 81
      3 => """
      89010123
      78121874
      87430965
      96549874
      45678903
      32019012
      01329801
      10456732
      """
    }

    content[@content]
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, 0}, fn line, {map, y} ->
      {Enum.reduce(String.split(line, "", trim: true), {map, 0}, fn n, {map, x} ->
         try do
           n = String.to_integer(n)
           {Map.put(map, n, MapSet.put(Map.get(map, n, MapSet.new()), {x, y})), x + 1}
         rescue
           ArgumentError -> {map, x + 1}
         end
       end)
       |> elem(0), y + 1}
    end)
    |> elem(0)
  end

  defp put_or_join({ms, path_counts}, pos, path_count) do
    {MapSet.put(ms, pos), Map.put(path_counts, pos, Map.get(path_counts, pos, 0) + path_count)}
  end

  defp next_step(map, elev, up, acc, path_count) do
    if MapSet.member?(map[elev], up), do: put_or_join(acc, up, path_count), else: acc
  end

  defp climb_to_nine(_map, {ms, path_counts}, elev) when elev == 9, do: {ms, path_counts}

  defp climb_to_nine(map, {ms, path_counts}, elev) do
    # IO.inspect({elev, MapSet.to_list(ms), path_counts}, label: "Climbing")
    elev = elev + 1

    {next_ms, next_path_counts} =
      Enum.reduce(MapSet.to_list(ms), {MapSet.new(), path_counts}, fn {x, y},
                                                                      {_ms, path_counts} = acc ->
        path_count = Map.get(path_counts, {x, y})

        Enum.reduce([{x, y - 1}, {x - 1, y}, {x, y + 1}, {x + 1, y}], acc, fn pos, acc ->
          next_step(map, elev, pos, acc, path_count)
        end)
      end)

    climb_to_nine(map, {next_ms, next_path_counts}, elev)
  end

  defp to_nine(map, pos) do
    ms = MapSet.new([pos])
    path_counts = %{pos => 1}

    climb_to_nine(map, {ms, path_counts}, 0)
  end

  defp part1_time(map) do
    map[0]
    |> MapSet.to_list()
    |> Enum.map(&to_nine(map, &1))
    |> Enum.map(fn {nines, paths_set} -> {MapSet.to_list(nines), paths_set} end)
    |> Enum.map(fn {nines, path_set} ->
      {Enum.count(nines),
       Enum.reduce(nines, 0, fn nine, acc -> Map.get(path_set, nine) + acc end)}
    end)
    |> Enum.reduce({0, 0}, fn {count, path_count}, {ncount, npath_count} ->
      {ncount + count, npath_count + path_count}
    end)

    # |> IO.inspect(label: "Result")
  end

  defp part1(map) do
    {time, {count, _path_count}} = :timer.tc(&part1_time/1, [map])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp part2_time(map) do
    part1_time(map)
  end

  defp part2(map) do
    {time, {_count, path_count}} = :timer.tc(&part2_time/1, [map])
    IO.puts("Part 2: #{path_count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    map = read_input()
    part1(map)
    part2(map)
  end
end
