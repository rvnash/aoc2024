defmodule D09Test do
  require Integer
  use ExUnit.Case

  def read_input do
    {:ok, content} = File.read("./test/09.txt")
    IO.puts("Disk size: #{content |> String.length()}")

    # content = """
    # 2333133121414131402
    # """

    content
    |> String.trim()
    |> String.codepoints()
    |> Enum.reduce({[], false, 0}, fn n, {acc, on_free?, id} ->
      n = String.to_integer(n)

      if n == 0 do
        case on_free? do
          false ->
            {acc, not on_free?, id + 1}

          true ->
            {acc, not on_free?, id}
        end
      else
        case on_free? do
          false ->
            {
              Enum.reverse(
                for block_num <- 0..(n - 1) do
                  {id, block_num}
                end
              ) ++
                acc,
              not on_free?,
              id + 1
            }

          true ->
            {for _block_num <- 0..(n - 1) do
               {:free}
             end ++ acc, not on_free?, id}
        end
      end
    end)
    |> elem(0)
    |> Enum.reverse()

    # |> IO.inspect(label: "Disk")
  end

  def swap(a, {i_first, i_last}, i2) do
    # IO.inspect({i_first, i_last, i2}, label: "Swapping")
    len = i_last - i_first + 1
    before = Enum.slice(a, 0, i2)
    left = Enum.slice(a, i2, len)
    middle = Enum.slice(a, i2 + len, i_first - (i2 + len))
    right = Enum.slice(a, i_first, len)
    rest = Enum.slice(a, i_last + 1, Enum.count(a) - i_last)

    # IO.inspect(
    #   %{"before" => before, "left" => left, "middle" => middle, "right" => right, "rest" => rest},
    #   label: "Swap"
    # )

    before ++ right ++ middle ++ left ++ rest
  end

  def swap(a, i1, i2) do
    e1 = Enum.at(a, i1)
    e2 = Enum.at(a, i2)

    a
    |> List.replace_at(i1, e2)
    |> List.replace_at(i2, e1)
  end

  def find_gap(disk) do
    first_free = Enum.find_index(disk, fn x -> x == {:free} end)

    last_non_free =
      Enum.count(disk) - Enum.find_index(Enum.reverse(disk), fn x -> x != {:free} end) - 1

    {first_free, last_non_free}
  end

  defp compress(disk) do
    {fiirst_free, last_non_free} = find_gap(disk)
    # IO.inspect({fiirst_free, last_non_free}, label: "Gaps")

    if last_non_free < fiirst_free do
      disk
    else
      compress(swap(disk, fiirst_free, last_non_free))
    end
  end

  defp checksum(disk) do
    disk
    |> Enum.reduce({0, 0}, fn block, {sum, pos} ->
      case block do
        {:free} -> {sum, pos + 1}
        {id, _} -> {sum + pos * id, pos + 1}
      end
    end)
    |> elem(0)
  end

  defp part1_time(disk) do
    compress(disk)
    # |> IO.inspect(label: "Compressed")
    |> checksum()
  end

  defp part1(disk) do
    {time, count} = :timer.tc(&part1_time/1, [disk])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp find_range(disk, id) do
    first =
      Enum.find_index(disk, fn block ->
        case block do
          {:free} -> false
          {block_id, _} -> block_id == id
        end
      end)

    last =
      Enum.count(disk) -
        Enum.find_index(Enum.reverse(disk), fn block ->
          case block do
            {:free} -> false
            {block_id, _} -> block_id == id
          end
        end) - 1

    {first, last}
  end

  defp find_gap_of(disk, size) do
    # IO.inspect(size, label: "Finding Gap OF")

    count =
      Enum.chunk_by(disk, fn block ->
        case block do
          {:free} -> {:free}
          {id, _} -> id
        end
      end)
      |> Enum.reduce_while(0, fn [hd | _] = blocks, acc ->
        gap_size = Enum.count(blocks)

        if hd == {:free} and gap_size >= size do
          {:halt, acc}
        else
          {:cont, acc + gap_size}
        end
      end)

    if count < Enum.count(disk) do
      count
    else
      nil
    end

    # |> IO.inspect(label: "Gap Found")
  end

  defp part2_time(disk) do
    max_id = disk |> Enum.reverse() |> Enum.find(fn block -> block != {:free} end) |> elem(0)

    for id <- max_id..0//-1, reduce: disk do
      acc ->
        # IO.puts("Checking #{id}")
        {first, last} = find_range(acc, id)
        # IO.inspect({first, last}, label: "Range")
        gap = find_gap_of(acc, last - first + 1)

        if gap != nil and first > gap do
          # IO.puts("Gap: #{gap}")

          # |> IO.inspect(label: "Swapped")
          acc |> swap({first, last}, gap)
        else
          acc
        end
    end
    # |> IO.inspect(label: "Compressed")
    |> checksum()
  end

  defp part2(disk) do
    {time, count} = :timer.tc(&part2_time/1, [disk])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  test "Day 9" do
    IO.puts("Day 9 - No time for subtlety this is all brute force and very slow")
    disk = read_input()
    part1(disk)
    part2(disk)
  end
end
