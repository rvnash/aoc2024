defmodule D13 do
  require Integer
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself
  @content 0
  @debug false

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      Button A: X+94, Y+34
      Button B: X+22, Y+67
      Prize: X=8400, Y=5400

      Button A: X+26, Y+66
      Button B: X+67, Y+21
      Prize: X=12748, Y=12176

      Button A: X+17, Y+86
      Button B: X+84, Y+37
      Prize: X=7870, Y=6450

      Button A: X+69, Y+23
      Button B: X+27, Y+71
      Prize: X=18641, Y=10279
      """
    }

    machines =
      content[@content]
      |> String.split("\n", trim: true)
      |> Enum.chunk_every(3)
      |> Enum.map(fn [buttona, buttonb, prize] ->
        %{a: get_two_ints(buttona), b: get_two_ints(buttonb), prize: get_two_ints(prize)}
      end)

    if @debug, do: IO.inspect(machines, label: "Machines"), else: machines
  end

  defp get_two_ints(str) do
    String.split(str, ~r{[^\d]+}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp det_2x2({{a, b}, {c, d}}) do
    a * d - b * c
  end

  defp inv_2x2({{a, b}, {c, d}} = mat) do
    det = det_2x2(mat)
    # Should probably check for det == 0, but I know higher level code will handle that
    det_inv = 1.0 / det
    {{d * det_inv, -b * det_inv}, {-c * det_inv, a * det_inv}}
  end

  defp solve_2x2(mat, {x, y}) do
    {{a, b}, {c, d}} = inv_2x2(mat)
    {a * x + b * y, c * x + d * y}
  end

  defp check_solution(
         %{a: {ax, ay}, b: {bx, by}, prize: {px, py}} = _machine,
         a_presses,
         b_presses
       ) do
    {px, py} == {ax * a_presses + bx * b_presses, ay * a_presses + by * b_presses}
  end

  defp cost_to_get_prize(%{a: {ax, ay}, b: {bx, by}, prize: prize} = machine) do
    mat = {{ax, bx}, {ay, by}}

    case det_2x2(mat) do
      0 ->
        # The machine represents parallel lines (i.e. no solutions)
        # The input data doesn't do this to us,
        # but just in case print out this line and return 0
        IO.puts("Machine #{inspect(machine)} parallel lines")
        0

      _ ->
        {a_presses, b_presses} = solve_2x2(mat, prize)

        # The above solution is done in float numbers, but rounding to the nearest integer may break the solution
        {a_presses, b_presses} = {round(a_presses), round(b_presses)}

        case check_solution(machine, a_presses, b_presses) do
          true -> a_presses * 3 + b_presses * 1
          false -> 0
        end
    end
  end

  defp part1_time(machines), do: Enum.map(machines, &cost_to_get_prize(&1)) |> Enum.sum()

  defp part1(machines) do
    {time, count} = :timer.tc(&part1_time/1, [machines])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp machines_plus_10000000000000(machines) do
    machines
    |> Enum.map(fn machine ->
      %{
        machine
        | prize:
            {elem(machine.prize, 0) + 10_000_000_000_000,
             elem(machine.prize, 1) + 10_000_000_000_000}
      }
    end)
  end

  defp part2_time(machines), do: machines |> machines_plus_10000000000000() |> part1_time()

  defp part2(machines) do
    {time, count} = :timer.tc(&part2_time/1, [machines])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    machines = read_input()
    part1(machines)
    part2(machines)
  end
end
