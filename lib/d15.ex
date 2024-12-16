defmodule D15 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      ########
      #..O.O.#
      ##@.O..#
      #...O..#
      #.#.O..#
      #...O..#
      #......#
      ########

      <^^>>>vv<v>>v<<
      """,
      2 => """
      ##########
      #..O..O.O#
      #......O.#
      #.OO..O.O#
      #..O@..O.#
      #O#..O...#
      #O..O..O.#
      #.OO.O.OO#
      #....O...#
      ##########

      <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
      vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
      ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
      <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
      ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
      ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
      >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
      <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
      ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
      v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
      """,
      3 => """
      #######
      #...#.#
      #.....#
      #..OO@#
      #..O..#
      #.....#
      #######

      <vv<<v<^^^
      """
      # <vv<<^^<<^^
    }

    {warehouse_content, path_content} =
      content[@content]
      |> String.trim()
      |> String.split("\n")
      |> Enum.split_while(fn line -> line != "" end)

    warehouse_state =
      Enum.reduce(
        warehouse_content,
        {%{
           robot_pos: {0, 0},
           boxes: MapSet.new(),
           big_boxes: MapSet.new(),
           walls: MapSet.new()
         }, 0},
        fn line, {warehouse_state, row} ->
          {Enum.reduce(String.split(line, "", trim: true), {warehouse_state, 0}, fn char,
                                                                                    {warehouse_state,
                                                                                     col} ->
             {
               case char do
                 "#" -> %{warehouse_state | walls: MapSet.put(warehouse_state.walls, {col, row})}
                 "O" -> %{warehouse_state | boxes: MapSet.put(warehouse_state.boxes, {col, row})}
                 "@" -> %{warehouse_state | robot_pos: {col, row}}
                 _ -> warehouse_state
               end,
               col + 1
             }
           end)
           |> elem(0), row + 1}
        end
      )
      |> elem(0)

    # IO.inspect(warehouse_state, label: "Warehouse State")

    moves =
      path_content
      |> Enum.join()
      |> String.split("", trim: true)
      |> Enum.map(fn char ->
        case char do
          "<" -> {-1, 0}
          ">" -> {+1, 0}
          "^" -> {0, -1}
          "v" -> {0, +1}
          _ -> :noop
        end
      end)
      |> Enum.filter(&(&1 != :noop))

    # IO.inspect(moves, label: "Moves")
    {warehouse_state, moves}
  end

  # defp get_grid_str(warehouse_state) do
  #   width = (MapSet.to_list(warehouse_state.walls) |> Enum.map(&elem(&1, 0)) |> Enum.max()) + 1
  #   height = (MapSet.to_list(warehouse_state.walls) |> Enum.map(&elem(&1, 1)) |> Enum.max()) + 1

  #   lines =
  #     Enum.reduce(0..(height - 1), [], fn y, acc ->
  #       [
  #         Enum.reduce(0..(width - 1), [], fn x, acc ->
  #           if MapSet.member?(warehouse_state.walls, {x, y}) do
  #             ["#" | acc]
  #           else
  #             if big_box_at_position(warehouse_state, {x, y}) do
  #               case big_box_side(warehouse_state, {x, y}) do
  #                 :left -> ["[" | acc]
  #                 :right -> ["]" | acc]
  #                 :none -> IO.puts("Error in state")
  #               end
  #             else
  #               if box_at_position(warehouse_state, {x, y}) do
  #                 ["O" | acc]
  #               else
  #                 if {x, y} == warehouse_state.robot_pos do
  #                   ["@" | acc]
  #                 else
  #                   ["." | acc]
  #                 end
  #               end
  #             end
  #           end
  #         end)
  #         | acc
  #       ]
  #     end)

  #   Enum.reverse(lines) |> Enum.map(&Enum.join(Enum.reverse(&1))) |> Enum.join("\n")
  # end

  defp plus({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  defp mul({x, y}, {nx, ny}) do
    {x * nx, y * ny}
  end

  defp compute_gps(warehouse_state) do
    MapSet.to_list(warehouse_state.boxes)
    |> Enum.map(fn {x, y} -> y * 100 + x end)
    |> Enum.sum()

    +(MapSet.to_list(warehouse_state.big_boxes)
      |> Enum.map(fn {x, y} -> y * 100 + x end)
      |> Enum.sum())
  end

  defp find_place_for_box(warehouse_state, pos, dir) do
    new_pos = plus(pos, dir)

    if MapSet.member?(warehouse_state.walls, new_pos) do
      nil
    else
      if box_at_position(warehouse_state, new_pos) do
        find_place_for_box(warehouse_state, new_pos, dir)
      else
        new_pos
      end
    end
  end

  defp box_at_position(warehouse_state, pos) do
    MapSet.member?(warehouse_state.boxes, pos)
  end

  defp big_box_at_position(warehouse_state, pos) do
    MapSet.member?(warehouse_state.big_boxes, pos) or
      MapSet.member?(warehouse_state.big_boxes, plus(pos, {-1, 0}))
  end

  defp big_box_side(warehouse_state, pos) do
    if MapSet.member?(warehouse_state.big_boxes, pos) do
      :left
    else
      if MapSet.member?(warehouse_state.big_boxes, plus(pos, {-1, 0})) do
        :right
      else
        :none
      end
    end
  end

  # defp tup({x, y}) do
  #   "{#{x}, #{y}}"
  # end

  defp big_box_on_wall(warehouse_state, pos) do
    MapSet.member?(warehouse_state.walls, pos) or
      MapSet.member?(warehouse_state.walls, plus(pos, {1, 0}))
  end

  defp normalize_box_pos(warehouse_state, pos) do
    if big_box_side(warehouse_state, pos) == :left do
      pos
    else
      plus(pos, {-1, 0})
    end
  end

  defp boxes_at(warehouse_state, pos) do
    [
      if big_box_at_position(warehouse_state, pos) do
        pos
      else
        nil
      end,
      if big_box_at_position(warehouse_state, plus(pos, {1, 0})) do
        plus(pos, {1, 0})
      else
        nil
      end
    ]
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(&normalize_box_pos(warehouse_state, &1))
    |> Enum.uniq()
  end

  defp maybe_move_big_box(warehouse_state, pos, dir) do
    box_pos = normalize_box_pos(warehouse_state, pos)
    new_pos = plus(box_pos, dir)

    if big_box_on_wall(warehouse_state, new_pos) do
      nil
    else
      case dir do
        {-1, 0} ->
          if big_box_at_position(warehouse_state, new_pos) do
            case maybe_move_big_box(warehouse_state, new_pos, dir) do
              nil ->
                nil

              new_warehouse_state ->
                %{
                  new_warehouse_state
                  | big_boxes:
                      MapSet.delete(new_warehouse_state.big_boxes, box_pos)
                      |> MapSet.put(new_pos)
                }
            end
          else
            %{
              warehouse_state
              | big_boxes:
                  MapSet.delete(warehouse_state.big_boxes, box_pos)
                  |> MapSet.put(new_pos)
            }
          end

        {1, 0} ->
          right_box_pos = box_pos |> plus(dir) |> plus(dir)

          if big_box_at_position(warehouse_state, right_box_pos) do
            case maybe_move_big_box(warehouse_state, right_box_pos, dir) do
              nil ->
                nil

              new_warehouse_state ->
                %{
                  new_warehouse_state
                  | big_boxes:
                      MapSet.delete(new_warehouse_state.big_boxes, pos)
                      |> MapSet.put(new_pos)
                }
            end
          else
            %{
              warehouse_state
              | big_boxes:
                  MapSet.delete(warehouse_state.big_boxes, box_pos)
                  |> MapSet.put(new_pos)
            }
          end

        {0, _deltay} ->
          boxes = boxes_at(warehouse_state, new_pos)

          if boxes != [] do
            case Enum.reduce(boxes, warehouse_state, fn box_pos, acc ->
                   if acc == nil do
                     nil
                   else
                     case maybe_move_big_box(acc, box_pos, dir) do
                       nil ->
                         nil

                       new_warehouse_state ->
                         %{
                           new_warehouse_state
                           | big_boxes:
                               MapSet.delete(new_warehouse_state.big_boxes, box_pos)
                               |> MapSet.put(new_pos)
                         }
                     end
                   end
                 end) do
              nil ->
                nil

              new_warehouse_state ->
                %{
                  new_warehouse_state
                  | big_boxes:
                      MapSet.delete(new_warehouse_state.big_boxes, box_pos)
                      |> MapSet.put(new_pos)
                }
            end
          else
            %{
              warehouse_state
              | big_boxes:
                  MapSet.delete(warehouse_state.big_boxes, box_pos)
                  |> MapSet.put(new_pos)
            }
          end
      end
    end
  end

  defp maybe_move_robot(warehouse_state, pos, dir) do
    if MapSet.member?(warehouse_state.walls, pos) do
      # Hit a wall
      warehouse_state
    else
      if box_at_position(warehouse_state, pos) do
        # Hit a box
        case find_place_for_box(warehouse_state, pos, dir) do
          nil ->
            warehouse_state

          new_pos ->
            %{
              warehouse_state
              | robot_pos: pos,
                boxes:
                  MapSet.delete(warehouse_state.boxes, pos)
                  |> MapSet.put(new_pos)
            }
        end
      else
        if big_box_at_position(warehouse_state, pos) do
          # Hit a big box
          case maybe_move_big_box(warehouse_state, pos, dir) do
            nil ->
              warehouse_state

            new_warehouse_state ->
              %{new_warehouse_state | robot_pos: pos}
          end
        else
          %{warehouse_state | robot_pos: pos}
        end
      end
    end
  end

  defp move(warehouse_state, dir) do
    warehouse_state = maybe_move_robot(warehouse_state, plus(warehouse_state.robot_pos, dir), dir)
    warehouse_state
  end

  defp part1_time({warehouse_state, moves}) do
    moves |> Enum.reduce(warehouse_state, &move(&2, &1)) |> compute_gps()
  end

  defp part1({warehouse_state, moves}) do
    {time, count} = :timer.tc(&part1_time/1, [{warehouse_state, moves}])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  # ----------------------------------------------

  defp make_big_warehouse(warehouse_state) do
    %{
      robot_pos: mul(warehouse_state.robot_pos, {2, 1}),
      boxes: MapSet.new(),
      big_boxes:
        MapSet.to_list(warehouse_state.boxes)
        |> Enum.map(fn {x, y} -> mul({x, y}, {2, 1}) end)
        |> MapSet.new(),
      walls:
        MapSet.to_list(warehouse_state.walls)
        |> Enum.map(fn {x, y} -> [mul({x, y}, {2, 1}), mul({x, y}, {2, 1}) |> plus({1, 0})] end)
        |> List.flatten()
        |> MapSet.new()
    }
  end

  defp part2_time({warehouse_state, moves}) do
    big_warehouse_state = make_big_warehouse(warehouse_state)
    part1_time({big_warehouse_state, moves})
  end

  defp part2({warehouse_state, moves}) do
    {time, count} = :timer.tc(&part2_time/1, [{warehouse_state, moves}])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    {warehouse_state, moves} = read_input()
    part1({warehouse_state, moves})
    part2({warehouse_state, moves})
  end
end
