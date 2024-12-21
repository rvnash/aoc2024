defmodule D21 do
  @numeric "
    789
    456
    123
    .0A
  "

  @directional "
    .^A
    <V>
  "

  def parse_keyboard(keyboard) do
    keyboard
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.trim()
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {key, x} -> {key, {x, y}} end)
    end)
    |> Map.new()
  end

  def parse(_) do
    text = File.read!("./lib/21.txt")

    codes =
      text
      |> String.split("\n")
      |> Enum.map(fn line ->
        line |> String.codepoints()
      end)

    numeric = parse_keyboard(@numeric)
    directional = parse_keyboard(@directional)

    {codes, numeric, directional}
  end

  def directional_presses({prev_x, prev_y}, {next_x, next_y}, {avoid_x, avoid_y}) do
    x = next_x - prev_x
    xchar = if x < 0, do: "<", else: ">"
    xs = List.duplicate(xchar, abs(x))
    y = next_y - prev_y
    ychar = if y < 0, do: "^", else: "V"
    ys = List.duplicate(ychar, abs(y))

    x_first = xs ++ ys ++ ["A"]
    y_first = ys ++ xs ++ ["A"]

    cond do
      prev_y == avoid_y and next_x == avoid_x -> [y_first]
      prev_x == avoid_x and next_y == avoid_y -> [x_first]
      true -> [x_first, y_first]
    end
  end

  def presses(code, [], cache), do: {Enum.count(code), cache}

  def presses(code, keyboards, cache) do
    key = {code, keyboards}

    case cache do
      %{^key => result} ->
        {result, cache}

      _ ->
        [keyboard | sub_keyboards] = keyboards
        start = Map.get(keyboard, "A")
        avoid = Map.get(keyboard, ".")

        code
        |> Enum.reduce({0, start, cache}, fn button, {acc, prev, cache} ->
          next = Map.get(keyboard, button)

          {sub_presses, cache} =
            directional_presses(prev, next, avoid)
            |> Enum.reduce({[], cache}, fn sub_code, {sub_presses, cache} ->
              {presses, cache} = presses(sub_code, sub_keyboards, cache)
              {[presses | sub_presses], cache}
            end)

          {acc + Enum.min(sub_presses), next, cache}
        end)
        |> then(fn {total, _next, cache} -> {total, cache |> Map.put(key, total)} end)
    end
  end

  def solve({codes, numeric, directional}, n) do
    keyboards = [numeric] ++ List.duplicate(directional, n)

    codes
    |> Enum.reduce({0, %{}}, fn code, {total, cache} ->
      {presses, cache} = presses(code, keyboards, cache)
      number = code |> Enum.reject(&(&1 == "A")) |> Enum.join() |> String.to_integer()
      {total + presses * number, cache}
    end)
    |> elem(0)
  end

  def part(1, file) do
    file |> parse() |> solve(2)
  end

  def part(2, file) do
    file |> parse() |> solve(25)
  end

  def run(part, input) do
    {time, value} = :timer.tc(&part/2, [part, input])
    time = :erlang.float_to_binary(time / 1000, decimals: 1)

    IO.inspect(value, label: "Part #{part} #{input} (#{time}ms)", charlists: :as_lists)
  end

  def run() do
    # Stolen from here https://github.com/liamcmitchell/advent-of-code/blob/main/2024/21/1.exs
    IO.puts("FAILED 2024 Day 21, this is someone elses code")
    D21.run(1, "input")
    D21.run(2, "input")
  end
end
