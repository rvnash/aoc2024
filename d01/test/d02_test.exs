defmodule D02Test do
  use ExUnit.Case
  doctest D01

  def read_lists do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/02.txt")

    # content = """
    # 7 6 4 2 1
    # 1 2 7 8 9
    # 9 7 6 2 1
    # 1 3 2 4 5
    # 8 6 4 4 1
    # 1 3 6 7 9
    # """

    lists =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    lists
  end

  def is_increasing(list) do
    list |> Stream.chunk_every(2, 1, :discard) |> Enum.all?(fn [a, b] -> a < b end)
  end

  def is_decreasing(list) do
    list |> Stream.chunk_every(2, 1, :discard) |> Enum.all?(fn [a, b] -> a > b end)
  end

  def max_change_less_than(list, n) do
    list |> Stream.chunk_every(2, 1, :discard) |> Enum.all?(fn [a, b] -> abs(a - b) < n end)
  end

  def is_safe(list) do
    (is_increasing(list) or is_decreasing(list)) and max_change_less_than(list, 4)
  end

  def is_safe_dampener(list) do
    case is_safe(list) do
      true ->
        true

      false ->
        0..(Enum.count(list) - 1)
        |> Enum.any?(fn i ->
          l = List.delete_at(list, i)
          is_safe(l)
        end)
    end
  end

  test "Day 2" do
    IO.puts("Day 2")
    lists = read_lists()

    safe_count =
      Enum.reduce(lists, 0, fn list, acc ->
        (is_safe(list) && acc + 1) || acc
      end)

    IO.inspect(safe_count, label: "Safe count")

    safe_dampener_count =
      Enum.reduce(lists, 0, fn list, acc ->
        (is_safe_dampener(list) && acc + 1) || acc
      end)

    IO.inspect(safe_dampener_count, label: "Safe count w/ dampener")
  end
end
