defmodule D04Test do
  use ExUnit.Case

  def read_input do
    {:ok, content} = File.read("/Users/nash/src/aoc2024/d01/test/04.txt")

    # content = """
    # MMMSXXMASM
    # MSAMXMSMSA
    # AMXSXMAAMM
    # MSAMASMSMX
    # XMASAMXAMM
    # XXAMMXXAMA
    # SMSMSASXSS
    # SAXAMASAAA
    # MAMMMXMMMM
    # MXMXAXMASX
    # """

    array =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        Arrays.new(String.split(line, "", trim: true))
      end)
      |> Arrays.new()

    array
  end

  defp get_left_right(array) do
    Enum.map(array, fn row ->
      Enum.reduce(row, "", fn letter, acc ->
        acc <> letter
      end)
    end)
  end

  defp get_top_bottom(array) do
    for col <- 0..(Arrays.size(array[0]) - 1) do
      for row <- 0..(Arrays.size(array) - 1), reduce: "" do
        acc ->
          acc <> array[row][col]
      end
    end
  end

  defp get_top_left_to_bottom_right(array) do
    width = Arrays.size(array[0])
    height = Arrays.size(array)

    for col <- 0..(height + width - 1) do
      for c <- 0..(width - 1), reduce: "" do
        acc ->
          r = height - col - 1 + c

          if c < 0 or c > height - 1 or r < 0 or r > width - 1 do
            acc
          else
            acc <> array[r][c]
          end
      end
    end
  end

  defp get_top_right_to_bottom_left(array) do
    width = Arrays.size(array[0])
    height = Arrays.size(array)

    for col <- 0..(height + width - 1) do
      for c <- 0..(width - 1), reduce: "" do
        acc ->
          r = col - c

          if c < 0 or c > height - 1 or r < 0 or r > width - 1 do
            acc
          else
            acc <> array[r][c]
          end
      end
    end
  end

  defp get_eight_strings(array) do
    lr = get_left_right(array)
    tb = get_top_bottom(array)
    tlbr = get_top_left_to_bottom_right(array)
    trbl = get_top_right_to_bottom_left(array)

    [
      lr,
      Enum.map(lr, &String.reverse/1),
      tb,
      Enum.map(tb, &String.reverse/1),
      tlbr,
      Enum.map(tlbr, &String.reverse/1),
      trbl,
      Enum.map(trbl, &String.reverse/1)
    ]
    |> List.flatten()
  end

  defp part1_timed(array) do
    eight_strings = get_eight_strings(array)

    Enum.reduce(eight_strings, 0, fn str, count ->
      count + (Regex.scan(~r/XMAS/, str, capture: :all) |> Enum.count())
    end)
  end

  defp part1(array) do
    {time, part1} = :timer.tc(&part1_timed/1, [array])
    IO.puts("Part 1: #{part1} in #{time / 1000}ms")
  end

  defp sum_at(array, kernel, x, y) do
    kw = Arrays.size(kernel[0])
    kh = Arrays.size(kernel)

    for kx <- 0..(kw - 1), reduce: 0 do
      acc ->
        for ky <- 0..(kh - 1), reduce: acc do
          acc ->
            acc + if array[y + ky][x + kx] == kernel[ky][kx], do: 1, else: 0
        end
    end
  end

  defp convolve(array, kernel) do
    w = Arrays.size(array[0])
    h = Arrays.size(array)
    kw = Arrays.size(kernel[0])
    kh = Arrays.size(kernel)

    for x <- 0..(w - kw), reduce: Arrays.new() do
      acc ->
        row =
          for y <- 0..(h - kh), reduce: Arrays.new() do
            acc ->
              Arrays.append(acc, sum_at(array, kernel, x, y))
          end

        Arrays.append(acc, row)
    end
  end

  defp count5(array) do
    Enum.reduce(array, 0, fn row, acc ->
      Enum.reduce(row, acc, fn value, acc ->
        if value == 5 do
          acc + 1
        else
          acc
        end
      end)
    end)
  end

  defp brute_force_it(array) do
    w = Arrays.size(array[0]) - 1
    h = Arrays.size(array) - 1

    {_, count} =
      Enum.reduce(array, {0, 0}, fn row_array, {row, count} ->
        if row > 0 and row < h do
          top_array = array[row - 1]
          bot_array = array[row + 1]

          {_, count} =
            Enum.reduce(row_array, {0, count}, fn value, {col, count} ->
              if col > 0 and col < w and value == "A" do
                case [
                  top_array[col - 1],
                  bot_array[col + 1],
                  bot_array[col - 1],
                  top_array[col + 1]
                ] do
                  ["M", "S", "M", "S"] ->
                    {col + 1, count + 1}

                  ["M", "S", "S", "M"] ->
                    {col + 1, count + 1}

                  ["S", "M", "M", "S"] ->
                    {col + 1, count + 1}

                  ["S", "M", "S", "M"] ->
                    {col + 1, count + 1}

                  _ ->
                    {col + 1, count}
                end
              else
                {col + 1, count}
              end
            end)

          {row + 1, count}
        else
          {row + 1, count}
        end
      end)

    count
  end

  defp conv_it(array) do
    conv1 =
      convolve(
        array,
        Arrays.new([
          Arrays.new(["M", ".", "S"]),
          Arrays.new([".", "A", "."]),
          Arrays.new(["M", ".", "S"])
        ])
      )

    conv2 =
      convolve(
        array,
        Arrays.new([
          Arrays.new(["S", ".", "M"]),
          Arrays.new([".", "A", "."]),
          Arrays.new(["S", ".", "M"])
        ])
      )

    conv3 =
      convolve(
        array,
        Arrays.new([
          Arrays.new(["M", ".", "M"]),
          Arrays.new([".", "A", "."]),
          Arrays.new(["S", ".", "S"])
        ])
      )

    conv4 =
      convolve(
        array,
        Arrays.new([
          Arrays.new(["S", ".", "S"]),
          Arrays.new([".", "A", "."]),
          Arrays.new(["M", ".", "M"])
        ])
      )

    count5(conv1) + count5(conv2) + count5(conv3) + count5(conv4)
  end

  defp part2(array) do
    {time_a, total_a} = :timer.tc(&conv_it/1, [array])
    {time_b, total_b} = :timer.tc(&brute_force_it/1, [array])

    # Wrote it two ways, convolution and just looking for the pattern
    IO.puts("Part 2 Method A: #{total_a} in #{time_a / 1000}ms")
    IO.puts("Part 2 Method B: #{total_b} in #{time_b / 1000}ms")
  end

  test "Day 4" do
    IO.puts("Day 4")

    array = read_input()
    part1(array)
    part2(array)
  end
end
