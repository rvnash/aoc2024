defmodule D03Test do
  use ExUnit.Case

  def read_input do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/03.txt")

    # content = """
    # xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    # """

    content
  end

  test "Day 3" do
    IO.puts("Day 3")
    input = read_input()

    muls =
      Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, input, capture: :all)
      |> Enum.reduce(0, fn [_mul, arg1, arg2], total ->
        String.to_integer(arg1) * String.to_integer(arg2) + total
      end)

    IO.puts("Part 1: #{muls}")

    {_, muls2} =
      Regex.scan(~r/(?:mul\((\d{1,3}),(\d{1,3})\)|don't\(\)|do\(\))/, input, capture: :all)
      |> Enum.reduce({:do, 0}, fn command, {do_state, total} ->
        case command do
          ["don't()"] ->
            {:dont, total}

          ["do()"] ->
            {:do, total}

          [_mul, arg1, arg2] ->
            case do_state do
              :dont -> {do_state, total}
              :do -> {do_state, String.to_integer(arg1) * String.to_integer(arg2) + total}
            end
        end
      end)

    IO.puts("Part 2: #{muls2}")
  end
end
