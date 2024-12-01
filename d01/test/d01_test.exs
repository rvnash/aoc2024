defmodule D01Test do
  use ExUnit.Case
  doctest D01

  def read_lists do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/lists.txt")

    {list1, list2} =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [a, b] = String.split(line, " ", trim: true)
        {String.to_integer(a), String.to_integer(b)}
      end)
      |> Enum.unzip()

    {list1, list2}
  end

  test "Day 1" do
    IO.puts("Day 1")
    {list1, list2} = read_lists()
    zipped = Enum.zip(Enum.sort(list1), Enum.sort(list2))
    dist = Enum.reduce(zipped, 0, fn {a, b}, acc -> acc + abs(a - b) end)
    IO.inspect(dist, label: "Distance")

    frequencies = Enum.frequencies(list2)

    similarity =
      Enum.reduce(list1, 0, fn x, acc ->
        case frequencies[x] do
          nil -> acc
          f -> acc + f * x
        end
      end)

    IO.inspect(similarity, label: "Similarity")
    assert D01.hello() == :world
  end
end
