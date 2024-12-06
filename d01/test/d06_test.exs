defmodule D06Test do
  require Integer
  use ExUnit.Case

  defstruct w: 0,
            h: 0,
            obstructions: MapSet.new(),
            loc: {0, 0},
            facing: {0, -1},
            step_count: 0,
            on_map?: true,
            visitted: MapSet.new(),
            previous_guard_states: MapSet.new(),
            in_loop?: false

  defp add_char(state, char, col, row) do
    case char do
      "." ->
        state

      "#" ->
        %{state | obstructions: MapSet.put(state.obstructions, {col, row})}

      "^" ->
        %{
          state
          | loc: {col, row},
            facing: {0, -1},
            visitted: MapSet.put(state.visitted, {col, row}),
            previous_guard_states: MapSet.put(state.previous_guard_states, {{col, row}, {0, -1}})
        }
    end
  end

  def read_map do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/06.txt")

    # content = """
    # ....#.....
    # .........#
    # ..........
    # ..#.......
    # .......#..
    # ..........
    # .#..^.....
    # ........#.
    # #.........
    # ......#...
    # """

    array =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, "", trim: true)
      end)

    Enum.reduce(array, {0, %__MODULE__{}}, fn line, {row, state} ->
      {row + 1,
       Enum.reduce(line, {0, state}, fn char, {col, state} ->
         state =
           if col >= state.w or row >= state.h do
             %{state | w: col + 1, h: row + 1}
           else
             state
           end

         {col + 1, add_char(state, char, col, row)}
       end)
       |> elem(1)}
    end)
    |> elem(1)
  end

  defp turn_right({0, -1}), do: {1, 0}
  defp turn_right({1, 0}), do: {0, 1}
  defp turn_right({0, 1}), do: {-1, 0}
  defp turn_right({-1, 0}), do: {0, -1}

  def step(
        %{
          loc: loc = {lx, ly},
          facing: facing = {fx, fy},
          obstructions: obstructions,
          previous_guard_states: previous_guard_states,
          visitted: visitted
        } = state
      ) do
    new_loc = {lx + fx, ly + fy}

    if MapSet.member?(obstructions, new_loc) do
      turn_right = turn_right(facing)
      guard_state = {loc, turn_right}

      %{
        state
        | facing: turn_right,
          previous_guard_states: MapSet.put(previous_guard_states, guard_state),
          in_loop?: MapSet.member?(previous_guard_states, guard_state)
      }
    else
      {x, y} = new_loc
      on_map? = x >= 0 and x < state.w and y >= 0 and y < state.h
      guard_state = {new_loc, state.facing}

      %{
        state
        | loc: new_loc,
          visitted: (on_map? && MapSet.put(state.visitted, new_loc)) || visitted,
          on_map?: on_map?,
          previous_guard_states: MapSet.put(previous_guard_states, guard_state),
          in_loop?: MapSet.member?(previous_guard_states, guard_state)
      }
    end
  end

  def run_until_off_map_or_in_loop(state) when state.on_map? and not state.in_loop? do
    run_until_off_map_or_in_loop(step(state))
  end

  def run_until_off_map_or_in_loop(state) do
    state
  end

  defp part1(state) do
    {time, state} = :timer.tc(&run_until_off_map_or_in_loop/1, [state])
    count = MapSet.size(state.visitted)
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp get_possible_new_obstruction_positions(state) do
    # Return everywhere the guard visits, minus the starting location
    start_loc = state.loc
    state = run_until_off_map_or_in_loop(state)

    MapSet.delete(state.visitted, start_loc)
    |> MapSet.to_list()
  end

  defp new_pos_produces_loop?(state, new_pos) do
    state =
      run_until_off_map_or_in_loop(%{
        state
        | obstructions: MapSet.put(state.obstructions, new_pos)
      })

    state.in_loop?
  end

  defp count_looping_obstructions(state, obstructions) do
    Enum.reduce(obstructions, 0, fn ob_pos, count ->
      if new_pos_produces_loop?(state, ob_pos) do
        count + 1
      else
        count
      end
    end)
  end

  defp part2_concurrent(state) do
    obstructions = get_possible_new_obstruction_positions(state)
    max_concurrency = System.schedulers_online() * 32

    Enum.chunk_every(obstructions, max_concurrency)
    |> Enum.map(fn obstructions_chunk ->
      Task.async(fn -> count_looping_obstructions(state, obstructions_chunk) end)
    end)
    |> Enum.map(fn task -> Task.await(task, :infinity) end)
    |> Enum.sum()
  end

  defp part2(state) do
    {time, count} = :timer.tc(&part2_concurrent/1, [state])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  test "Day 6" do
    IO.puts("Day 6")

    state =
      read_map()

    part1(state)
    part2(state)
  end
end
