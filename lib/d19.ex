defmodule D19 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      r, wr, b, g, bwu, rb, gb, br

      brwrr
      bggr
      gbbr
      rrbgbr
      ubwu
      bwurrg
      brgr
      bbrgwb
      """
    }

    [available | patterns] =
      content[@content]
      |> String.trim()
      |> String.split("\n", trim: true)

    towels =
      String.split(available, ", ")
      |> Enum.sort(fn a, b -> String.length(a) > String.length(b) end)

    {towels, patterns}
    # |> IO.inspect(label: "Available and Patterns")
  end

  defp possible_to_match?(_towels, _rest, ""), do: true
  defp possible_to_match?(_, [], _), do: false

  defp possible_to_match?(towels, [towel | rest_of_towels], pattern) do
    # IO.inspect({towel, pattern}, label: "Towel and Pattern")

    case pattern do
      <<^towel::binary, rest_of_pattern::binary>> ->
        possible_to_match?(towels, towels, rest_of_pattern)

      _ ->
        false
    end or
      possible_to_match?(towels, rest_of_towels, pattern)
  end

  defp part1_time({towels, patterns}) do
    Enum.map(patterns, fn pattern ->
      possible_to_match?(towels, towels, pattern)
    end)
    |> Enum.count(& &1)
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  # ----------------------------------------------
  defp ways_to_match(_towesl, ""), do: 1

  defp ways_to_match(towels, pattern) do
    case Process.get(pattern) do
      nil ->
        count =
          Enum.reduce(towels, 0, fn towel, sum ->
            case pattern do
              <<^towel::binary, rest_of_pattern::binary>> ->
                ways_to_match(towels, rest_of_pattern) + sum

              _ ->
                sum
            end
          end)

        Process.put(pattern, count)
        count

      cached_sum ->
        cached_sum
    end

    # |> IO.inspect(label: "Final for #{pattern}")
  end

  defp part2_time({towels, patterns}) do
    # patterns = ["gbbr"]

    Task.async_stream(patterns, fn pattern ->
      ways_to_match(towels, pattern)
      # System.halt()
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
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
