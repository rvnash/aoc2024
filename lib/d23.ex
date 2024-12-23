defmodule D23 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      kh-tc
      qp-kh
      de-cg
      ka-co
      yn-aq
      qp-ub
      cg-tb
      vc-aq
      tb-ka
      wh-tc
      yn-cg
      kh-ub
      ta-co
      de-co
      tc-td
      tb-wq
      wh-td
      ta-ka
      td-qp
      aq-cg
      wq-ub
      ub-vc
      de-ta
      wq-aq
      wq-vc
      wh-yn
      ka-de
      kh-ta
      co-tc
      wh-qp
      tb-vc
      td-yn
      """
    }

    {computers, connections, t_s} =
      content[@content]
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.reduce({MapSet.new(), %{}, MapSet.new()}, fn line, {computers, connections, t_s} ->
        [from_str, to_str] = String.split(line, "-")
        [from, to] = [String.to_atom(from_str), String.to_atom(to_str)]

        computers = MapSet.put(computers, from)
        computers = MapSet.put(computers, to)
        t_s = (String.starts_with?(from_str, "t") && MapSet.put(t_s, from)) || t_s
        t_s = (String.starts_with?(to_str, "t") && MapSet.put(t_s, to)) || t_s

        connections =
          Map.put(connections, from, MapSet.put(Map.get(connections, from, MapSet.new()), to))

        connections =
          Map.put(connections, to, MapSet.put(Map.get(connections, to, MapSet.new()), from))

        {computers, connections, t_s}
      end)

    # |> IO.inspect(label: "Parsed")

    {computers |> MapSet.to_list() |> Enum.sort(), connections, t_s}
  end

  defp is_all_connected?([], _), do: true

  defp is_all_connected?([computer | rest], connections) do
    connected = Map.get(connections, computer, MapSet.new())

    Enum.all?(rest, &MapSet.member?(connected, &1)) and is_all_connected?(rest, connections)
  end

  defp connected_to_themseves(computers, connections, filter_combo_fn) do
    Enum.reduce(computers, {MapSet.new(), 0}, fn computer, {connected_sets, largest_so_far} ->
      connected_to = MapSet.to_list(Map.get(connections, computer, MapSet.new()))
      combos = combinations(connected_to)

      combos =
        Enum.filter(combos, &filter_combo_fn.(&1, computer, {connected_sets, largest_so_far}))

      connected_combos = Enum.filter(combos, &is_all_connected?(&1, connections))

      Enum.reduce(connected_combos, {connected_sets, largest_so_far}, fn combo,
                                                                         {connected_sets,
                                                                          largest_so_far} ->
        new_set = [computer | combo] |> Enum.sort()
        count = Enum.count(new_set)

        {
          MapSet.put(connected_sets, {new_set, count}),
          max(largest_so_far, count)
        }
      end)
    end)
    |> elem(0)
  end

  defp combinations([]), do: [[]]

  defp combinations([h | tail]) do
    tails = combinations(tail)
    for(t <- tails, do: [h | t]) ++ tails
  end

  defp part1_time({computers, connections, t_s}) do
    connected_to_themseves(computers, connections, fn combo, computer, _ ->
      Enum.count(combo) == 2 and
        (MapSet.member?(t_s, computer) or Enum.any?(combo, &MapSet.member?(t_s, &1)))
    end)
    |> Enum.count()
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  defp part2_time({computers, connections, _t_s}) do
    connected_to_themseves(computers, connections, fn combo,
                                                      _,
                                                      {_connected_sets, largest_so_far} ->
      Enum.count(combo) >= largest_so_far
    end)
    |> Enum.max_by(fn {_a, count} -> count end)
    |> elem(0)
    |> Enum.join(",")
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
