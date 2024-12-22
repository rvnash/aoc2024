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

    # solve(content[@content], part: 2) |> IO.inspect(label: "Solve part 2")

    content[@content]
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp next(secret_number) do
    secret_number = rem(bxor(secret_number * 64, secret_number), 16_777_216)
    secret_number = rem(bxor(div(secret_number, 32), secret_number), 16_777_216)
    rem(bxor(secret_number * 2048, secret_number), 16_777_216)
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
    all_sequences =
      Enum.reduce(buyers_sequences, [], fn sequences, acc ->
        Enum.reduce(Map.keys(sequences), acc, fn sequence, acc ->
          [sequence | acc]
        end)
      end)
      |> Enum.uniq()

    IO.inspect(Enum.count(all_sequences), label: "Total sequences")

    # Enum.map(buyers_sequences, fn sequences ->
    #   Map.get(sequences, {0, -1, 0, 1}, 0)
    # end)
    # |> Enum.sort()
    # |> IO.inspect(label: "Example", limit: :infinity)

    Enum.reduce(all_sequences, {nil, 0}, fn sequence, {best_sequence, best_price} ->
      price =
        Enum.map(buyers_sequences, fn sequences ->
          Map.get(sequences, sequence, 0)
        end)
        |> Enum.sum()

      if price == 1831 do
        IO.puts("Sequence: #{price} #{inspect(sequence)}")
      end

      if price == 1881 do
        IO.puts("Sequence: #{price} #{inspect(sequence)}")
      end

      if price > best_price do
        {sequence, price}
      else
        {best_sequence, best_price}
      end
    end)
    |> IO.inspect(label: "Best sequence")
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

    # IO.inspect(buyers_prices, label: "prices")

    buyers_diffs =
      Enum.map(buyers_prices, fn prices ->
        {first, rest} = List.pop_at(prices, 0)

        Enum.reduce(rest, {first, [:na]}, fn price, {prev, diffs} ->
          {price, [price - prev | diffs]}
        end)
        |> elem(1)
        |> Enum.reverse()
      end)

    # IO.inspect(buyers_diffs, label: "Diffs")

    buyers_sequences =
      Enum.map(Enum.zip(buyers_diffs, buyers_prices), fn {diffs, prices} ->
        {d0, diffs} = List.pop_at(diffs, 0)
        {d1, diffs} = List.pop_at(diffs, 0)
        {d2, diffs} = List.pop_at(diffs, 0)
        {d3, diffs} = List.pop_at(diffs, 0)
        first = {d0, d1, d2, d3}

        {_, prices} = List.pop_at(prices, 0)
        {_, prices} = List.pop_at(prices, 0)
        {_, prices} = List.pop_at(prices, 0)
        {_, prices} = List.pop_at(prices, 0)

        Enum.reduce(
          Enum.zip(diffs, prices),
          {first, %{}},
          fn {diff, price}, {{_d0, d1, d2, d3}, sequences} ->
            sequence = {d1, d2, d3, diff}

            if price > Map.get(sequences, sequence, 0) do
              {sequence, Map.put(sequences, sequence, price)}
            else
              {sequence, sequences}
            end
          end
        )
        |> elem(1)
      end)

    # IO.inspect(Enum.zip(buyers_prices, buyers_diffs),
    #   label: "Price and diffs"
    # )

    # IO.inspect(buyers_sequences,
    #   label: "Sequences"
    # )

    find_best_sequence(buyers_sequences)
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

  defp parse(input) do
    input |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def solve(input, part: 2) do
    {sequences_to_price, consecutive_changes} =
      input
      |> parse()
      |> Enum.map_reduce([], fn initial, acc ->
        prices =
          1..2000
          |> Enum.reduce([initial], fn _, [head | _tail] = acc ->
            [evolve(head)] ++ acc
          end)
          |> Enum.reverse()
          |> Enum.map(&rem(&1, 10))

        prices_as_map = prices |> Enum.with_index() |> Map.new(fn {price, i} -> {i, price} end)

        consecutive_changes =
          prices
          |> Enum.chunk_every(2, 1, :discard)
          |> Enum.map(fn [l, r] -> r - l end)
          |> Enum.chunk_every(4, 1, :discard)

        sequence_to_price =
          for {consecutive_change, i} <-
                consecutive_changes |> Enum.with_index(4) |> Enum.reverse(),
              reduce: %{} do
            acc ->
              Map.put(acc, consecutive_change, prices_as_map[i])
          end

        {sequence_to_price, consecutive_changes ++ acc}
      end)

    for sequence_to_price <- sequences_to_price, reduce: [] do
      acc ->
        [sequence_to_price[[0, -1, 0, 1]] || 0 | acc]
    end
    |> Enum.sort()
    |> IO.inspect(label: "Prices", limit: :infinity)

    consecutive_changes
    |> MapSet.new()
    |> Enum.map(fn consecutive_change ->
      price =
        for sequence_to_price <- sequences_to_price, reduce: 0 do
          acc ->
            acc + (sequence_to_price[consecutive_change] || 0)
        end

      if price == 1831 do
        IO.puts("Sequence: #{price} #{inspect(consecutive_change)}")
      end

      if price == 1881 do
        IO.puts("Sequence: #{price} #{inspect(consecutive_change)}")
      end

      price
    end)
    |> Enum.max()
  end

  def evolve(secret_number) do
    secret_number = rem(bxor(secret_number * 64, secret_number), 16_777_216)
    secret_number = rem(bxor(div(secret_number, 32), secret_number), 16_777_216)
    secret_number = rem(bxor(secret_number * 2048, secret_number), 16_777_216)

    secret_number
  end
end
