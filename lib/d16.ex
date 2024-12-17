defmodule D16 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  # def read_input do
  #   content = %{
  #     0 => File.read!("./lib/#{@aoc_day}.txt"),
  #     1 => """
  #     ###############
  #     #.......#....E#
  #     #.#.###.#.###.#
  #     #.....#.#...#.#
  #     #.###.#####.#.#
  #     #.#.#.......#.#
  #     #.#.#####.###.#
  #     #...........#.#
  #     ###.#.#####.#.#
  #     #...#.....#.#.#
  #     #.#.#.###.#.#.#
  #     #.....#...#.#.#
  #     #.###.#.#.#.#.#
  #     #S..#.....#...#
  #     ###############
  #     """,
  #     2 => """
  #     #################
  #     #...#...#...#..E#
  #     #.#.#.#.#.#.#.#.#
  #     #.#.#.#...#...#.#
  #     #.#.#.#.###.#.#.#
  #     #...#.#.#.....#.#
  #     #.#.#.#.#.#####.#
  #     #.#...#.#.#.....#
  #     #.#.#####.#.###.#
  #     #.#.#.......#...#
  #     #.#.###.#####.###
  #     #.#.#...#.....#.#
  #     #.#.#.#####.###.#
  #     #.#.#.........#.#
  #     #.#.#.#########.#
  #     #S#.............#
  #     #################
  #     """
  #   }

  #   content[@content]
  #   |> String.trim()
  #   |> String.split("\n", trim: true)
  #   |> Enum.reduce(
  #     {%{
  #        reindeer: nil,
  #        end_tile: nil,
  #        walls: MapSet.new()
  #      }, 0},
  #     fn line, {maze_state, row} ->
  #       {Enum.reduce(String.split(line, "", trim: true), {maze_state, 0}, fn char,
  #                                                                            {maze_state, col} ->
  #          {
  #            case char do
  #              "#" ->
  #                %{maze_state | walls: MapSet.put(maze_state.walls, {col, row})}

  #              "S" ->
  #                %{
  #                  maze_state
  #                  | reindeer: %{
  #                      position: {col, row},
  #                      facing: {1, 0},
  #                      score: 0
  #                    }
  #                }

  #              "E" ->
  #                %{maze_state | end_tile: {col, row}}

  #              _ ->
  #                maze_state
  #            end,
  #            col + 1
  #          }
  #        end)
  #        |> elem(0), row + 1}
  #     end
  #   )
  #   |> elem(0)

  #   # |> IO.inspect(label: "Maze Start")
  # end

  # defp get_grid_str(reindeer, walls, end_tile) do
  #   width = (MapSet.to_list(walls) |> Enum.map(&elem(&1, 0)) |> Enum.max()) + 1
  #   height = (MapSet.to_list(walls) |> Enum.map(&elem(&1, 1)) |> Enum.max()) + 1

  #   Enum.reduce((height - 1)..0//-1, [], fn y, acc ->
  #     [
  #       Enum.reduce((width - 1)..0//-1, [], fn x, acc ->
  #         if reindeer.position == {x, y} do
  #           case reindeer.facing do
  #             {0, -1} -> ["^" | acc]
  #             {1, 0} -> [">" | acc]
  #             {0, 1} -> ["v" | acc]
  #             {-1, 0} -> ["<" | acc]
  #           end
  #         else
  #           if end_tile == {x, y} do
  #             ["E" | acc]
  #           else
  #             if MapSet.member?(walls, {x, y}) do
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

  # defp part1_time(maze_state) do
  #   0
  # end

  # defp part1(maze_state) do
  #   {time, count} = :timer.tc(&part1_time/1, [maze_state])
  #   IO.puts("Part 1: #{count} in #{time / 1000}ms")
  # end

  # # ----------------------------------------------

  # defp part2_time(_maze_state) do
  #   0
  # end

  # defp part2(maze_state) do
  #   {time, count} = :timer.tc(&part2_time/1, [maze_state])
  #   IO.puts("Part 2: #{count} in #{time / 1000}ms")
  # end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    IO.puts("FAILED TO SOLVE")
  end
end
