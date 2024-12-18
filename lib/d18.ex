defmodule D18 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  # Live content: 1024
  # Example: 12
  @drops 1024

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      5,4
      4,2
      4,5
      3,0
      2,1
      6,3
      2,4
      1,5
      0,6
      3,3
      2,6
      5,1
      1,2
      5,5
      2,5
      6,5
      1,4
      0,4
      6,4
      1,1
      6,1
      1,0
      0,5
      1,6
      2,0
      """
    }

    content[@content]
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)

    # |> IO.inspect(label: "Falling Bytes")
  end

  defp get_width_height(falling_bytes) do
    max_x = Enum.max(Enum.map(falling_bytes, fn {x, _} -> x end))
    max_y = Enum.max(Enum.map(falling_bytes, fn {_, y} -> y end))
    {max_x + 1, max_y + 1}
  end

  defp make_grid(0, _, grid), do: grid
  defp make_grid(_, [], grid), do: grid

  defp make_grid(byte_count, [location | rest], grid) do
    make_grid(byte_count - 1, rest, MapSet.put(grid, location))
  end

  defp make_grid(byte_count, falling_bytes) do
    make_grid(byte_count, falling_bytes, MapSet.new())
  end

  # -------------------------------------------
  defp add_paths(grid, w, h, paths, visited, {x, y}, score, passed) do
    score = score + 1

    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Enum.reduce({paths, visited}, fn {x, y} = pos, {paths, visited} ->
      passed = [pos | passed]

      if x < 0 or x >= w or y < 0 or y >= h do
        {paths, visited}
      else
        if MapSet.member?(visited, pos) do
          # IO.inspect(pos, label: "Visited? #{inspect(visited)} #{MapSet.member?(visited, pos)}")
          {paths, visited}
        else
          if MapSet.member?(grid, pos) do
            {paths, visited}
          else
            {:gb_sets.insert({score, pos, passed}, paths), MapSet.put(visited, pos)}
          end
        end
      end
    end)
  end

  defp explore_paths(grid, w, h, paths, visited, end_pos) do
    if :gb_sets.is_empty(paths) do
      :failed
    else
      case :gb_sets.take_smallest(paths) do
        {{_score, ^end_pos, passed}, _} ->
          passed

        {{score, position, passed}, paths} ->
          # IO.puts(
          #   "Score: #{score} Position: #{inspect(position)} Passed: #{Enum.count(passed)} Visited: #{Enum.count(visited)} Paths: #{:gb_sets.size(paths)}"
          # )

          {paths, visited} = add_paths(grid, w, h, paths, visited, position, score, passed)
          explore_paths(grid, w, h, paths, visited, end_pos)
      end
    end
  end

  defp shortest_path_time(grid, w, h, start_pos, end_pos) do
    paths = :gb_sets.singleton({0, start_pos, []})
    explore_paths(grid, w, h, paths, MapSet.new(), end_pos)
  end

  defp part1_time(falling_bytes) do
    grid = make_grid(@drops, falling_bytes)
    {w, h} = get_width_height(falling_bytes)

    shortest_path_time(grid, w, h, {0, 0}, {w - 1, h - 1})
    |> Enum.count()
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  # ----------------------------------------------

  defp part2_time(falling_bytes) do
    {w, h} = get_width_height(falling_bytes)

    Enum.reduce_while(1025..Enum.count(falling_bytes), nil, fn drops, _ ->
      grid = make_grid(drops, falling_bytes)

      case shortest_path_time(grid, w, h, {0, 0}, {w - 1, h - 1}) do
        :failed -> {:halt, Enum.at(falling_bytes, drops - 1)}
        _ -> {:cont, drops}
      end
    end)
    |> then(&"#{elem(&1, 0)},#{elem(&1, 1)}")
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