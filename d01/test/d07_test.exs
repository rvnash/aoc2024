defmodule D07Test do
  require Integer
  use ExUnit.Case

  def read_map do
    {:ok, content} = File.read("./test/07.txt")

    # content = """
    # 190: 10 19
    # 3267: 81 40 27
    # 83: 17 5
    # 156: 15 6
    # 7290: 6 8 6 15
    # 161011: 16 10 13
    # 192: 17 8 14
    # 21037: 9 7 18 13
    # 292: 11 6 16 20
    # """

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [ans, operands] = String.split(line, ":", trim: true)

      [
        String.to_integer(ans),
        String.split(operands, " ", trim: true) |> Enum.map(&String.to_integer/1)
      ]
    end)
  end

  def cartesian_combos([]), do: [[]]

  def cartesian_combos([head | tail]) do
    for h <- head, t <- cartesian_combos(tail), do: [h | t]
  end

  def combinations(n, list) do
    Enum.map(1..n, fn _ -> list end)
    |> cartesian_combos()
  end

  defp compute([first | rest], ops) do
    Enum.zip(ops, rest)
    |> Enum.reduce(first, fn {operation, operand}, acc ->
      case operation do
        :add -> acc + operand
        :mul -> acc * operand
        :concat -> (Integer.digits(acc) ++ Integer.digits(operand)) |> Integer.undigits()
      end
    end)
  end

  defp can_find_solution(ans, operands, operations) do
    combinations(Enum.count(operands) - 1, operations)
    |> Enum.any?(fn op_list ->
      ans == compute(operands, op_list)
    end)
  end

  defp part1_time(eqs) do
    Enum.reduce(eqs, 0, fn [ans, operands], acc ->
      if can_find_solution(ans, operands, [:add, :mul]) do
        acc + ans
      else
        acc
      end
    end)
  end

  defp part1(eqs) do
    {time, count} = :timer.tc(&part1_time/1, [eqs])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp part2_time(eqs) do
    Enum.reduce(eqs, 0, fn [ans, operands], acc ->
      if can_find_solution(ans, operands, [:add, :mul, :concat]) do
        acc + ans
      else
        acc
      end
    end)
  end

  defp part2(eqs) do
    {time, count} = :timer.tc(&part2_time/1, [eqs])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  test "Day 7" do
    IO.puts("Day 7")
    eqs = read_map()
    part1(eqs)
    part2(eqs)
  end
end
