defmodule D17 do
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      Register A: 729
      Register B: 0
      Register C: 0

      Program: 0,1,5,4,3,0
      """,
      2 => """
      Register A: 117440
      Register B: 0
      Register C: 0

      Program: 0,3,5,4,3,0
      """
    }

    machine_state =
      content[@content]
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        case String.split(line, ": ") do
          ["Register A", value] ->
            {:a, String.to_integer(value)}

          ["Register B", value] ->
            {:b, String.to_integer(value)}

          ["Register C", value] ->
            {:c, String.to_integer(value)}

          ["Program", value] ->
            {:rom,
             String.split(value, ",", trim: true)
             |> Enum.map(&String.to_integer/1)
             |> Enum.with_index()
             |> Enum.map(fn {value, index} -> {index, value} end)
             |> Map.new()}
        end
      end)
      |> Map.new()
      |> Map.put(:ip, 0)
      |> Map.put(:state, :running)
      |> Map.put(:output, [])
      |> Map.put(:counter, 0)

    machine_state
  end

  def combo(machine_state, 4), do: machine_state.a
  def combo(machine_state, 5), do: machine_state.b
  def combo(machine_state, 6), do: machine_state.c
  def combo(_machine_state, 7), do: throw("Invalid combo operand, 7")
  def combo(_machine_state, operand), do: operand

  @adv 0
  @bxl 1
  @bst 2
  @jnz 3
  @bxc 4
  @out 5
  @bdv 6
  @cdv 7
  defp execute_opcode(machine_state, {@adv, operand}) do
    val = combo(machine_state, operand)
    %{machine_state | a: div(machine_state.a, Integer.pow(2, val)), ip: machine_state.ip + 2}
  end

  defp execute_opcode(machine_state, {@bxl, operand}) do
    %{machine_state | b: Bitwise.bxor(machine_state.b, operand), ip: machine_state.ip + 2}
  end

  defp execute_opcode(machine_state, {@bst, operand}) do
    val = combo(machine_state, operand)
    %{machine_state | b: Integer.mod(val, 8), ip: machine_state.ip + 2}
  end

  defp execute_opcode(machine_state, {@jnz, operand}) do
    %{
      machine_state
      | ip:
          if machine_state.a == 0 do
            machine_state.ip + 2
          else
            operand
          end
    }
  end

  defp execute_opcode(machine_state, {@bxc, _operand}) do
    %{machine_state | b: Bitwise.bxor(machine_state.b, machine_state.c), ip: machine_state.ip + 2}
  end

  defp execute_opcode(machine_state, {@out, operand}) do
    val = combo(machine_state, operand)

    %{
      machine_state
      | output: [Integer.mod(val, 8) | machine_state.output],
        ip: machine_state.ip + 2
    }
  end

  defp execute_opcode(machine_state, {@bdv, operand}) do
    val = combo(machine_state, operand)
    %{machine_state | b: div(machine_state.a, Integer.pow(2, val)), ip: machine_state.ip + 2}
  end

  defp execute_opcode(machine_state, {@cdv, operand}) do
    val = combo(machine_state, operand)
    %{machine_state | c: div(machine_state.a, Integer.pow(2, val)), ip: machine_state.ip + 2}
  end

  defp maybe_halt(machine_state) do
    if Map.has_key?(machine_state.rom, machine_state.ip) do
      machine_state
    else
      %{machine_state | state: :halted}
    end
  end

  defp increment_counter(machine_state) do
    %{machine_state | counter: machine_state.counter + 1}
  end

  defp execute_instruction(%{ip: ip, rom: rom, state: state} = machine_state)
       when state == :running do
    execute_opcode(machine_state, {rom[ip], rom[ip + 1]}) |> maybe_halt() |> increment_counter()
  end

  defp execute_instruction(machine_state), do: machine_state

  defp run_until_halt(machine_state) do
    case execute_instruction(machine_state) do
      %{state: :halted} = machine_state -> machine_state
      machine_state -> run_until_halt(machine_state)
    end
  end

  defp part1_time(machine_state) do
    machine_state = run_until_halt(machine_state)
    machine_state.output |> Enum.reverse() |> Enum.join(",")
  end

  defp part1(input) do
    {time, output} = :timer.tc(&part1_time/1, [input])
    IO.puts("Part 1: #{output} in #{time / 1000}ms")
  end

  # ----------------------------------------------

  defp rom_to_list(rom) do
    rom |> Map.to_list() |> Enum.sort() |> Enum.map(&elem(&1, 1))
  end

  defp solve_backward(machine_state) do
    rom = rom_to_list(machine_state.rom)

    Enum.reduce(1..Enum.count(machine_state.rom), [0], fn outputs, possible_as ->
      rom = Enum.reverse(rom) |> Enum.slice(0, outputs)

      Enum.map(possible_as, fn possible_a ->
        Enum.reduce(0..7, [], fn a, new_possibles ->
          a = possible_a * 8 + a
          new_machine_state = run_until_halt(%{machine_state | a: a})

          if new_machine_state.output == rom do
            [a | new_possibles]
          else
            new_possibles
          end
        end)
      end)
      |> List.flatten()
    end)
  end

  defp part2_time(machine_state) do
    solve_backward(machine_state) |> Enum.min()
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
