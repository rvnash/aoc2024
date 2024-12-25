defmodule D25 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      #####
      .####
      .####
      .####
      .#.#.
      .#...
      .....

      #####
      ##.##
      .#.##
      ...##
      ...#.
      ...#.
      .....

      .....
      #....
      #....
      #...#
      #.#.#
      #.###
      #####

      .....
      .....
      #.#..
      ###..
      ###.#
      ###.#
      #####

      .....
      .....
      .....
      #....
      #.#..
      #.#.#
      #####
      """
    }

    content[@content]
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(%{keys: [], locks: []}, fn device, map ->
      [first_line | _] = lines = String.split(device, "\n", trim: true)
      key = (first_line == "#####" && :keys) || :locks

      row_counts =
        Enum.reduce(lines, List.duplicate(-1, 5), fn line, space_count ->
          String.to_charlist(line)
          |> Enum.map(fn c -> (c == ?# && 1) || 0 end)
          |> Enum.zip(space_count)
          |> Enum.map(fn {c, s} -> c + s end)
        end)

      Map.put(map, key, [row_counts | Map.get(map, key)])
    end)
  end

  defp part1_time(%{keys: keys, locks: locks}) do
    for key <- keys, lock <- locks, reduce: 0 do
      total ->
        if Enum.all?(Enum.zip(key, lock), fn {k, l} -> k + l <= 5 end), do: total + 1, else: total
    end
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  defp part2_time(%{keys: _keys, locks: _locks}) do
    IO.puts("There is no part 2")
    0
  end

  defp part2(input) do
    {time, count} = :timer.tc(&part2_time/1, [input])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    input = read_input()
    part1(input)
    part2(input)
  end
end
