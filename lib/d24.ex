defmodule D24 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      x00: 1
      x01: 1
      x02: 1
      y00: 0
      y01: 1
      y02: 0

      x00 AND y00 -> z00
      x01 XOR y01 -> z01
      x02 OR y02 -> z02
      """,
      2 => """
      x00: 1
      x01: 0
      x02: 1
      x03: 1
      x04: 0
      y00: 1
      y01: 1
      y02: 1
      y03: 1
      y04: 1

      ntg XOR fgs -> mjb
      y02 OR x01 -> tnw
      kwq OR kpj -> z05
      x00 OR x03 -> fst
      tgd XOR rvg -> z01
      vdt OR tnw -> bfw
      bfw AND frj -> z10
      ffh OR nrd -> bqk
      y00 AND y03 -> djm
      y03 OR y00 -> psh
      bqk OR frj -> z08
      tnw OR fst -> frj
      gnj AND tgd -> z11
      bfw XOR mjb -> z00
      x03 OR x00 -> vdt
      gnj AND wpb -> z02
      x04 AND y00 -> kjc
      djm OR pbm -> qhw
      nrd AND vdt -> hwm
      kjc AND fst -> rvg
      y04 OR y02 -> fgs
      y01 AND x02 -> pbm
      ntg OR kjc -> kwq
      psh XOR fgs -> tgd
      qhw XOR tgd -> z09
      pbm OR djm -> kpj
      x03 XOR y03 -> ffh
      x00 XOR y04 -> ntg
      bfw OR bqk -> z06
      nrd XOR fgs -> wpb
      frj XOR qhw -> z04
      bqk OR frj -> z07
      y03 OR x01 -> nrd
      hwm AND bqk -> z03
      tgd XOR rvg -> z12
      tnw OR pbm -> gnj
      """,
      3 => """
      x00: 0
      x01: 1
      x02: 0
      x03: 1
      x04: 0
      x05: 1
      y00: 0
      y01: 0
      y02: 1
      y03: 1
      y04: 0
      y05: 1

      x00 AND y00 -> z05
      x01 AND y01 -> z02
      x02 AND y02 -> z01
      x03 AND y03 -> z03
      x04 AND y04 -> z04
      x05 AND y05 -> z00
      """
    }

    [gates_content, wires_content] = String.split(content[@content], "\n\n", trim: true)

    {
      gates_content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [gate, state] = String.split(line, ": ", trim: true)
        {gate, String.to_integer(state)}
      end)
      |> Map.new(),
      wires_content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_, g1, op, g2, go] = Regex.run(~r/(.*) (.*) (.*) -> (.*)/, line)
        {g1, String.to_atom(op), g2, go}
      end)
    }
  end

  defp get_op(_n, a, b) when a == nil or b == nil, do: nil
  defp get_op(:AND, a, b), do: ((a == 1 and b == 1) && 1) || 0
  defp get_op(:XOR, a, b), do: (((a == 0 and b == 1) or (a == 1 and b == 0)) && 1) || 0
  defp get_op(:OR, a, b), do: ((a == 1 or b == 1) && 1) || 0

  defp build_machine({gates, wires}) do
    Enum.reduce(wires, %{}, fn {g1, op, g2, go}, machine ->
      g1_state = Map.get(gates, g1)
      g2_state = Map.get(gates, g2)
      go_state = get_op(op, g1_state, g2_state)
      n = {{g1, g1_state}, op, {g2, g2_state}, {go, go_state}}
      machine |> Map.put(go, n)
    end)
  end

  defp propogate_outputs_to_inputs(machine) do
    Enum.reduce(machine, machine, fn {_k,
                                      {{_g1, _g1_state}, _op, {_g2, _g2_state}, {go, go_state}}},
                                     machine ->
      Enum.reduce(machine, machine, fn {_k,
                                        {{g1, g1_state}, op, {g2, g2_state},
                                         {go_next, go_state_next}}},
                                       machine ->
        case {g1, g1_state, g2, g2_state, go_state} do
          {_, _, _, _, nil} ->
            machine

          {^go, nil, _, _, _} ->
            Map.put(
              machine,
              go_next,
              {{g1, go_state}, op, {g2, g2_state}, {go_next, go_state_next}}
            )

          {_, _, ^go, nil, _} ->
            Map.put(
              machine,
              go_next,
              {{g1, g1_state}, op, {g2, go_state}, {go_next, go_state_next}}
            )

          {_, _, _, _, _} ->
            machine
        end
      end)
    end)
  end

  defp run_until_complete(machine) do
    machine = propogate_outputs_to_inputs(machine)

    outputs_we_could_compute =
      machine
      |> Map.to_list()
      |> Enum.filter(fn {_key, {{_g1, g1_state}, _op, {_g2, g2_state}, {_go, go_state}}} ->
        g1_state != nil and g2_state != nil and go_state == nil
      end)

    if Enum.empty?(outputs_we_could_compute) do
      machine
    else
      Enum.reduce(outputs_we_could_compute, machine, fn {_key,
                                                         {{g1, g1_state}, op, {g2, g2_state},
                                                          {go, _}}},
                                                        machine ->
        go_state = get_op(op, g1_state, g2_state)
        Map.put(machine, go, {{g1, g1_state}, op, {g2, g2_state}, {go, go_state}})
      end)
      |> run_until_complete()
    end
  end

  defp compute_output(machine, letter) do
    machine
    |> Map.to_list()
    |> Enum.reduce(MapSet.new(), fn {_, {{g1, g1_state}, _, {g2, g2_state}, {go, state}}}, acc ->
      acc
      |> MapSet.put({g1, g1_state})
      |> MapSet.put({g2, g2_state})
      |> MapSet.put({go, state})
    end)
    |> MapSet.to_list()
    |> Enum.sort(&(&1 >= &2))
    |> Enum.filter(fn {go, _} -> String.starts_with?("#{go}", letter) end)
    |> Enum.map(fn {_, state} -> state end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp part1_time({gates, wires}) do
    build_machine({gates, wires})
    |> run_until_complete()
    |> compute_output("z")
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  defp outputs_that_matter(outputs, machine) do
    new_outputs =
      Enum.reduce(outputs |> MapSet.to_list(), MapSet.new(), fn output, acc ->
        {{g1, _g1_state}, _op, {g2, _g2_state}, {_go, _go_state}} = Map.get(machine, output)

        acc =
          if not MapSet.member?(outputs, g2) and Map.get(machine, g2) != nil do
            MapSet.put(acc, g2)
          else
            acc
          end

        if not MapSet.member?(outputs, g1) and Map.get(machine, g1) != nil do
          MapSet.put(acc, g1)
        else
          acc
        end
      end)

    if MapSet.size(new_outputs) > 0 do
      outputs_that_matter(MapSet.union(outputs, new_outputs), machine)
    else
      outputs
    end
  end

  defp get_broken_zs({gates, wires}) do
    machine = build_machine({gates, wires})
    x = compute_output(machine, "x")
    y = compute_output(machine, "y")
    z = x + y

    actual_z = run_until_complete(machine) |> compute_output("z")

    Integer.digits(Bitwise.bxor(actual_z, z), 2)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.filter(fn {v, _} -> v == 1 end)
    |> Enum.map(fn {_, i} ->
      String.to_atom("z#{Integer.to_string(i) |> String.pad_leading(2, "0")}")
    end)
    |> Enum.map(fn z_output ->
      {z_output, outputs_that_matter(MapSet.new([z_output]), machine)}
    end)
    |> Enum.sort_by(fn {_, outputs} -> MapSet.size(outputs) end)
  end

  defp swap(wires, swap1, swap2) do
    {g1_1, op1, g2_1, go1} = Enum.find(wires, fn {_, _, _, go} -> go == swap1 end)
    {g1_2, op2, g2_2, go2} = Enum.find(wires, fn {_, _, _, go} -> go == swap2 end)
    wires = Enum.reject(wires, fn {_, _, _, go} -> go == swap1 or go == swap2 end)
    [{g1_1, op1, g2_1, go2} | [{g1_2, op2, g2_2, go1} | wires]]
  end

  defp find_swaps_to_fix({gates, wires}, swaps) do
    [first_z | broken_zs_w_outputs] = combinations_of_pairs_of_zs = get_broken_zs({gates, wires})

    IO.inspect(Enum.count(combinations_of_pairs_of_zs), labl: "Combinations")

    {{swap1, swap2}, count} =
      for second_z <- broken_zs_w_outputs, reduce: {nil, Enum.count(broken_zs_w_outputs)} do
        {best_swaps, best_count} ->
          {z1, outputs1} = first_z
          {z2, outputs2} = second_z
          IO.puts("Checking #{z1} and #{z2}")
          o1 = outputs1 |> MapSet.to_list()
          o2 = outputs2 |> MapSet.to_list()

          IO.puts(
            "o1 size #{Enum.count(o1)} x o2 size #{Enum.count(o2)} = #{Enum.count(o1) * Enum.count(o2)} "
          )

          for swap1 <- o1, swap2 <- o2, reduce: {best_swaps, best_count} do
            {best_swaps, best_count} ->
              if swap1 == swap2 do
                {best_swaps, best_count}
              else
                new_wires = swap(wires, swap1, swap2)
                new_broken_zs = get_broken_zs({gates, new_wires})
                count = Enum.count(new_broken_zs)

                if count < best_count do
                  {{swap1, swap2}, count}
                else
                  {best_swaps, best_count}
                end
              end
          end
      end

    if count == 0 do
      swaps
    else
      wires = swap(wires, swap1, swap2)
      swaps = [{swap1, swap2} | swaps]

      IO.puts("Swapping #{swap1} with #{swap2} new count = #{count}")
      find_swaps_to_fix({gates, wires}, swaps)
    end
  end

  defp to_atoms({gates, wires}) do
    {
      gates
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.new(),
      wires
      |> Enum.map(fn {g1, op, g2, go} ->
        {String.to_atom(g1), op, String.to_atom(g2), String.to_atom(go)}
      end)
    }
  end

  defp part2_time({gates, wires}) do
    {gates, wires} = to_atoms({gates, wires})

    find_swaps_to_fix({gates, wires}, [])
    |> IO.inspect(label: "Swaps")

    0
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
