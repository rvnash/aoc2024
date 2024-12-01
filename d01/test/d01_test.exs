defmodule D01Test do
  use ExUnit.Case
  doctest D01

  def read_lists do
    IO.puts("Reading lists")
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/lists.txt")

    {list1, list2} =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [a, b] = String.split(line, " ", trim: true)
        {String.to_integer(a), String.to_integer(b)}
      end)
      |> Enum.unzip()

    IO.inspect(list1, label: "List 1")
    IO.inspect(list2, label: "List 2")
    IO.puts("Done reading lists")
    {list1, list2}
  end

  test "greets the world" do
    {list1, list2} = read_lists()
    zipped = Enum.zip(Enum.sort(list1), Enum.sort(list2))
    IO.inspect(zipped, label: "Zipped")
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
