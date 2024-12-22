defmodule D22 do
  import Bitwise
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      1
      10
      100
      2024
      """,
      2 => """
      1
      2
      3
      2024
      """
    }

    content[@content]
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp next(secret_number) do
    secret_number = Integer.mod(bxor(secret_number * 64, secret_number), 16_777_216)
    secret_number = Integer.mod(bxor(div(secret_number, 32), secret_number), 16_777_216)
    Integer.mod(bxor(secret_number * 2048, secret_number), 16_777_216)
  end

  defp part1_time(buyers_secrets) do
    Enum.map(buyers_secrets, fn secret_number ->
      Enum.reduce(1..2000, secret_number, fn _n, secret_number ->
        next(secret_number)
      end)
    end)
    |> Enum.sum()
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  defp find_best_sequence(buyers_sequences) do
    Enum.reduce(buyers_sequences, %{}, fn sequences, merge ->
      Map.merge(sequences, merge, fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> Enum.max_by(fn {_sequence, bananas} -> bananas end)
  end

  defp part2_time(buyers_secrets) do
    buyers_prices =
      Enum.map(buyers_secrets, fn secret_number ->
        Enum.reduce(1..2000, {secret_number, []}, fn _n, {secret_number, prices} ->
          {next(secret_number), [Integer.mod(secret_number, 10) | prices]}
        end)
        |> elem(1)
        |> Enum.reverse()
      end)

    buyers_diffs =
      Enum.map(buyers_prices, fn prices ->
        [first | rest] = prices

        Enum.reduce(rest, {first, [:na]}, fn price, {prev, diffs} ->
          {price, [price - prev | diffs]}
        end)
        |> elem(1)
        |> Enum.reverse()
      end)

    Enum.map(Enum.zip(buyers_diffs, buyers_prices), fn {diffs, prices} ->
      [d0, d1, d2, d3 | diffs] = diffs
      first = {d0, d1, d2, d3}

      [_, _, _, _ | prices] = prices

      Enum.reduce(
        Enum.zip(diffs, prices),
        {first, %{}},
        fn {diff, price}, {{_d0, d1, d2, d3}, sequences} ->
          sequence = {d1, d2, d3, diff}
          {sequence, Map.put_new(sequences, sequence, price)}
        end
      )
      |> elem(1)
    end)
    |> find_best_sequence()
    |> elem(1)
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
