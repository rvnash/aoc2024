defmodule D11 do
  require Integer
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      125 17
      """,
      2 => "0"
    }

    content[@content]
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  defp split(n) do
    str = Integer.to_string(n)
    String.split_at(str, div(String.length(str), 2))
  end

  defp split_numeric(n) do
    {first, last} = split(n)
    {String.to_integer(first), String.to_integer(last)}
  end

  defp num_digits(n) do
    floor(:math.log10(n)) + 1
  end

  defp blink(stones) do
    Enum.reduce(stones, %{}, fn {stone, frequency}, acc ->
      cond do
        stone == 0 ->
          Map.put(acc, 1, Map.get(acc, 1, 0) + frequency)

        Integer.is_even(num_digits(stone)) ->
          {first, last} = split_numeric(stone)

          acc = acc |> Map.put(first, Map.get(acc, first, 0) + frequency)
          acc |> Map.put(last, Map.get(acc, last, 0) + frequency)

        true ->
          n = stone * 2024
          Map.put(acc, n, Map.get(acc, n, 0) + frequency)
      end
    end)
  end

  defp blinks(stones, 0), do: stones

  defp blinks(stones, n) do
    blinks(blink(stones), n - 1)
  end

  defp count_stones(stones) do
    Enum.reduce(stones, 0, fn {_, frequency}, acc -> acc + frequency end)
  end

  defp part1_time(stones) do
    blinks(stones, 25) |> count_stones()
  end

  defp part1(stones) do
    {time, count} = :timer.tc(&part1_time/1, [stones])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp part2_time(stones) do
    blinks(stones, 75) |> count_stones()
  end

  defp part2(stones) do
    {time, count} = :timer.tc(&part2_time/1, [stones])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    stones = read_input()
    part1(stones)
    part2(stones)
  end
end
