defmodule D12 do
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
      AAAA
      BBCD
      BBCC
      EEEC
      """,
      2 => """
      OOOOO
      OXOXO
      OOOOO
      OXOXO
      OOOOO
      """,
      3 => """
      AAAAAA
      AAABBA
      AAABBA
      ABBAAA
      ABBAAA
      AAAAAA
      """,
      4 => """
      RRRRIICCFF
      RRRRIICCCF
      VVRRRCCFFF
      VVRCCCJFFF
      VVVVCJJCFE
      VVIVCCJJEE
      VVIIICJJEE
      MIIIIIJJEE
      MIIISIJEEE
      MMMISSJEEE
      """,
      5 => """
      AA..
      .A..
      ..A.
      ....
      """
    }

    array =
      content[@content]
      |> String.split("\n", trim: true)
      |> pad_top_bottom()
      |> Enum.map(fn line ->
        Arrays.new(["."] ++ String.split(line, "", trim: true) ++ ["."])
      end)
      |> Arrays.new()

    if @debug, do: puts_map(array)
    array
  end

  def puts_map(original_map) do
    for y <- 0..(Arrays.size(original_map) - 1) do
      for x <- 0..(Arrays.size(original_map[y]) - 1) do
        IO.write(original_map[y][x])
      end

      IO.puts("")
    end

    original_map
  end

  defp pad_top_bottom([head | _] = array) do
    width = String.split(head, "", trim: true) |> Enum.count()
    [String.duplicate(".", width)] ++ array ++ [String.duplicate(".", width)]
  end

  defp perimeter_contribution(original_map, x, y, crop) do
    if(original_map[y - 1][x] != crop, do: 1, else: 0) +
      if(original_map[y + 1][x] != crop, do: 1, else: 0) +
      if(original_map[y][x + 1] != crop, do: 1, else: 0) +
      if original_map[y][x - 1] != crop, do: 1, else: 0
  end

  defp outside_top_right(original_map, x, y, crop) do
    if original_map[y - 1][x] != crop and original_map[y][x + 1] != crop, do: 1, else: 0
  end

  defp outside_bottom_right(original_map, x, y, crop) do
    if original_map[y][x + 1] != crop and original_map[y + 1][x] != crop, do: 1, else: 0
  end

  defp outside_top_left(original_map, x, y, crop) do
    if original_map[y][x - 1] != crop and original_map[y - 1][x] != crop, do: 1, else: 0
  end

  defp outside_bottom_left(original_map, x, y, crop) do
    if original_map[y][x - 1] != crop and original_map[y + 1][x] != crop, do: 1, else: 0
  end

  defp inside_top_right(original_map, x, y, crop) do
    if original_map[y - 1][x] == crop and original_map[y][x + 1] == crop and
         original_map[y - 1][x + 1] != crop,
       do: 1,
       else: 0
  end

  defp inside_bottom_right(original_map, x, y, crop) do
    if original_map[y][x + 1] == crop and original_map[y + 1][x] == crop and
         original_map[y + 1][x + 1] != crop,
       do: 1,
       else: 0
  end

  defp inside_top_left(original_map, x, y, crop) do
    if original_map[y - 1][x] == crop and original_map[y][x - 1] == crop and
         original_map[y - 1][x - 1] != crop,
       do: 1,
       else: 0
  end

  defp inside_bottom_left(original_map, x, y, crop) do
    if original_map[y][x - 1] == crop and original_map[y + 1][x] == crop and
         original_map[y + 1][x - 1] != crop,
       do: 1,
       else: 0
  end

  defp num_corners(original_map, x, y, crop) do
    outside_top_right(original_map, x, y, crop) +
      outside_bottom_right(original_map, x, y, crop) +
      outside_top_left(original_map, x, y, crop) +
      outside_bottom_left(original_map, x, y, crop) +
      inside_top_right(original_map, x, y, crop) +
      inside_bottom_right(original_map, x, y, crop) +
      inside_top_left(original_map, x, y, crop) +
      inside_bottom_left(original_map, x, y, crop)
  end

  defp build_region(original_map, visited_map, x, y, region) do
    region = Map.update!(region, :area, &(&1 + 1))

    region =
      Map.update!(
        region,
        :perimeter,
        &(&1 + perimeter_contribution(original_map, x, y, region.crop))
      )

    region = Map.update!(region, :sides, &(&1 + num_corners(original_map, x, y, region.crop)))
    visited_map = Arrays.replace(visited_map, y, Arrays.replace(visited_map[y], x, "."))

    {region, visited_map} =
      if visited_map[y - 1][x] == region.crop,
        do: build_region(original_map, visited_map, x, y - 1, region),
        else: {region, visited_map}

    {region, visited_map} =
      if visited_map[y + 1][x] == region.crop,
        do: build_region(original_map, visited_map, x, y + 1, region),
        else: {region, visited_map}

    {region, visited_map} =
      if visited_map[y][x - 1] == region.crop,
        do: build_region(original_map, visited_map, x - 1, y, region),
        else: {region, visited_map}

    {region, visited_map} =
      if visited_map[y][x + 1] == region.crop,
        do: build_region(original_map, visited_map, x + 1, y, region),
        else: {region, visited_map}

    {region, visited_map}
  end

  defp find_regions(_original_map, _visited_map, regions, _x, y, _w, h) when y == h, do: regions

  defp find_regions(original_map, visited_map, regions, x, y, w, h) do
    {regions, visited_map} =
      case visited_map[y][x] do
        "." ->
          {regions, visited_map}

        crop ->
          {region, visited_map} =
            build_region(original_map, visited_map, x, y, %{
              crop: crop,
              area: 0,
              perimeter: 0,
              sides: 0,
              apoint: {x, y}
            })

          {[region | regions], visited_map}
      end

    if x == w - 1 do
      find_regions(original_map, visited_map, regions, 0, y + 1, w, h)
    else
      find_regions(original_map, visited_map, regions, x + 1, y, w, h)
    end
  end

  defp calc_fencing(regions) do
    Enum.reduce(regions, 0, fn region, acc ->
      acc + region.perimeter * region.area
    end)
  end

  defp calc_fencing_sides(regions) do
    Enum.reduce(regions, 0, fn region, acc ->
      acc + region.sides * region.area
    end)
  end

  defp part1_time(original_map) do
    find_regions(
      original_map,
      original_map,
      [],
      0,
      0,
      Arrays.size(original_map[0]),
      Arrays.size(original_map)
    )
    |> calc_fencing()
  end

  defp part1(original_map) do
    {time, count} = :timer.tc(&part1_time/1, [original_map])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp part2_time(original_map) do
    find_regions(
      original_map,
      original_map,
      [],
      0,
      0,
      Arrays.size(original_map[0]),
      Arrays.size(original_map)
    )
    |> calc_fencing_sides()
  end

  defp part2(original_map) do
    {time, count} = :timer.tc(&part2_time/1, [original_map])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    original_map = read_input()
    part1(original_map)
    part2(original_map)
  end
end
