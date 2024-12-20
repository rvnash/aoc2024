defmodule D20 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0
  @savings_limit 100

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      ###############
      #...#...#.....#
      #.#.#.#.#.###.#
      #S#...#.#.#...#
      #######.#.#.###
      #######.#.#...#
      #######.#.###.#
      ###..E#...#...#
      ###.#######.###
      #...###...#...#
      #.#####.#.###.#
      #.#...#.#.#...#
      #.#.#.#.#.#.###
      #...#...#...###
      ###############
      """
    }

    content[@content]
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(
      %{s: nil, e: nil, walls: MapSet.new(), w: 0, h: 0},
      fn {line, row}, maze_state ->
        String.split(line, "", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(maze_state, fn {char, col}, maze_state ->
          maze_state = maybe_size(maze_state, {col, row})

          case char do
            "#" ->
              %{maze_state | walls: MapSet.put(maze_state.walls, {col, row})}

            "S" ->
              %{
                maze_state
                | s: {col, row}
              }

            "E" ->
              %{maze_state | e: {col, row}}

            _ ->
              maze_state
          end
        end)
      end
    )
  end

  defp maybe_size(maze_state, {x, y}) do
    %{maze_state | w: max(maze_state.w, x + 1), h: max(maze_state.h, y + 1)}
  end

  # defp get_grid_str(maze_state, pos, end_tile) do
  #   width = maze_state.w
  #   height = maze_state.h

  #   Enum.reduce((height - 1)..0//-1, [], fn y, acc ->
  #     [
  #       Enum.reduce((width - 1)..0//-1, [], fn x, acc ->
  #         if pos == {x, y} do
  #           ["S" | acc]
  #         else
  #           if end_tile == {x, y} do
  #             ["E" | acc]
  #           else
  #             if MapSet.member?(maze_state.walls, {x, y}) do
  #               ["#" | acc]
  #             else
  #               ["." | acc]
  #             end
  #           end
  #         end
  #       end)
  #       | acc
  #     ]
  #   end)
  # end

  defp add_paths(grid, w, h, {paths, visited}, {x, y}, passed, path_len) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.reduce({paths, visited}, fn {x, y} = pos, {paths, visited} ->
      if MapSet.member?(visited, pos) or MapSet.member?(grid, pos) or
           x < 0 or x >= w or y < 0 or
           y >= h do
        {paths, visited}
      else
        {:queue.in({pos, [{pos, path_len + 1} | passed], path_len + 1}, paths),
         MapSet.put(visited, pos)}
      end
    end)
  end

  defp explore_paths(grid, w, h, {paths, visited}, end_pos) do
    # My method assumes only one unique path to end in the non-cheat case
    # Halt if the assumption is wrong
    if :queue.to_list(paths) |> Enum.count() != 1 do
      IO.puts("queue length: #{:queue.to_list(paths) |> Enum.count()}")
      System.halt(1)
    end

    case :queue.out(paths) do
      {:empty, _} ->
        :failed

      {{:value, {^end_pos, passed, _path_len}}, _} ->
        passed

      {{:value, {position, passed, path_len}}, paths} ->
        explore_paths(
          grid,
          w,
          h,
          add_paths(grid, w, h, {paths, visited}, position, passed, path_len),
          end_pos
        )
    end
  end

  defp get_shortest_path(grid, w, h, start_pos, end_pos) do
    explore_paths(
      grid,
      w,
      h,
      {:queue.in({start_pos, [{start_pos, 0}], 0}, :queue.new()), MapSet.new([start_pos])},
      end_pos
    )
  end

  defp get_shortest_path(maze_state) do
    get_shortest_path(
      maze_state.walls,
      maze_state.w,
      maze_state.h,
      maze_state.s,
      maze_state.e
    )
  end

  defp make_cheat_list(maze_state, path_pos_to_time, max) do
    Enum.reduce(path_pos_to_time, %{}, fn {pos, _time}, map_of_cheats ->
      find_all_dests_within(maze_state, path_pos_to_time, pos, max, map_of_cheats)
    end)
  end

  defp city_block_dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp find_all_dests_within(
         %{w: w, h: h} = _maze_state,
         paths_pos_to_time,
         {startx, starty} = pos,
         dist,
         map_of_cheats
       ) do
    start_time = Map.get(paths_pos_to_time, pos)

    for x <- (startx - dist)..(startx + dist),
        y <- (starty - dist)..(starty + dist),
        x >= 0 and x < w and y > 0 and y < h and {x, y} != pos,
        reduce: map_of_cheats do
      acc ->
        end_pos = {x, y}
        end_dist = city_block_dist(pos, end_pos)

        if end_dist > dist or not Map.has_key?(paths_pos_to_time, end_pos) do
          acc
        else
          case Map.get(paths_pos_to_time, end_pos, nil) do
            nil ->
              acc

            end_time ->
              savings = end_time - start_time - end_dist

              if savings >= @savings_limit do
                Map.put(acc, {pos, end_pos}, savings)
              else
                acc
              end
          end
        end
    end
  end

  defp map_cheat_times_to_path_length(maze_state, max_cheat_length) do
    path_pos_to_time = get_shortest_path(maze_state) |> Map.new()

    make_cheat_list(maze_state, path_pos_to_time, max_cheat_length)
    |> Enum.group_by(fn {_cheat, savings} -> savings end)
    |> Enum.map(fn {savings, cheats} -> {savings, Enum.count(cheats)} end)
  end

  defp part1_time(maze_state) do
    map_cheat_times_to_path_length(maze_state, 2)
    |> Enum.map(fn {_savings, count} -> count end)
    |> Enum.sum()
  end

  defp part1(maze_state) do
    {time, count} = :timer.tc(&part1_time/1, [maze_state])
    IO.puts("Part 1: #{inspect(count, limit: :infinity)} in #{time / 1000}ms")
  end

  # ----------------------------------------------

  defp part2_time(maze_state) do
    map_cheat_times_to_path_length(maze_state, 20)
    |> Enum.map(fn {_savings, count} -> count end)
    |> Enum.sum()
  end

  defp part2(maze_state) do
    {time, count} = :timer.tc(&part2_time/1, [maze_state])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    input = read_input()
    part1(input)
    part2(input)
  end
end
