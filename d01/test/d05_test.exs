defmodule D04Test do
  require Integer
  use ExUnit.Case

  def read_rules do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/05rules.txt")

    # content = """
    # 47|53
    # 97|13
    # 97|61
    # 97|47
    # 75|29
    # 61|13
    # 75|53
    # 29|13
    # 97|29
    # 53|29
    # 61|53
    # 97|53
    # 61|29
    # 47|13
    # 75|47
    # 97|75
    # 47|61
    # 75|61
    # 47|29
    # 75|13
    # 53|13
    # """

    array =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, "|", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    array
  end

  def read_updates do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/05updates.txt")

    # content = """
    # 75,47,61,53,29
    # 97,61,53,29,13
    # 75,29,13
    # 75,97,47,61,53
    # 61,13,29
    # 97,13,75,29,47
    # """

    array =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    array
  end

  defp mid_value(list) do
    n = Enum.count(list)
    mid = div(n, 2)
    {mid_value, _} = List.pop_at(list, mid)
    mid_value
  end

  defp get_indices_of_rule(update, [bef, aft]) do
    {Enum.find_index(update, fn x -> bef == x end), Enum.find_index(update, fn x -> aft == x end)}
  end

  defp is_in_order_for_rule?(update, [bef, aft]) do
    {index_before, index_after} = get_indices_of_rule(update, [bef, aft])

    case {index_before, index_after} do
      {nil, _} ->
        true

      {_, nil} ->
        true

      {ib, ia} ->
        ib < ia
    end
  end

  defp is_in_order?(update, rules) do
    Enum.all?(rules, fn rule -> is_in_order_for_rule?(update, rule) end)
  end

  defp part1_time_me(rules, updates) do
    Enum.reduce(updates, 0, fn update, sum ->
      if is_in_order?(update, rules), do: sum + mid_value(update), else: sum
    end)
  end

  defp part1(rules, updates) do
    {time, result} = :timer.tc(&part1_time_me/2, [rules, updates])
    IO.puts("Part 1 #{result} in #{time / 1000}ms")
  end

  def swap(a, i1, i2) do
    e1 = Enum.at(a, i1)
    e2 = Enum.at(a, i2)

    a
    |> List.replace_at(i1, e2)
    |> List.replace_at(i2, e1)
  end

  defp a_before_b?(a, b, mapped_rules) do
    case Map.get(mapped_rules, a) do
      nil ->
        IO.puts("No rule for value #{a}")
        true

      mapset ->
        if MapSet.member?(mapset, b) do
          true
        else
          false
        end
    end
  end

  defp fix_order(update, mapped_rules) do
    Enum.sort(update, fn a, b ->
      a_before_b?(a, b, mapped_rules)
    end)
  end

  defp fix_order_return_middle(update, mapped_rules) do
    fix_order(update, mapped_rules) |> mid_value()
  end

  defp part2_time_me(rules, updates) do
    mapped_rules =
      Enum.reduce(rules, %{}, fn [bef, aft], map ->
        if Map.get(map, bef) do
          put_in(map[bef], MapSet.put(map[bef], aft))
        else
          Map.put(map, bef, MapSet.new([aft]))
        end
      end)

    Enum.reduce(updates, 0, fn update, sum ->
      if is_in_order?(update, rules),
        do: sum,
        else: sum + fix_order_return_middle(update, mapped_rules)
    end)
  end

  defp part2(rules, updates) do
    {time, result} = :timer.tc(&part2_time_me/2, [rules, updates])
    IO.puts("Part 1 #{result} in #{time / 1000}ms")
  end

  test "Day 5" do
    IO.puts("Day 5")

    rules = read_rules()
    updates = read_updates()
    part1(rules, updates)
    part2(rules, updates)
  end
end
