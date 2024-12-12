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

  def puts_map(omap) do
    for y <- 0..(Arrays.size(omap) - 1) do
      for x <- 0..(Arrays.size(omap[y]) - 1) do
        IO.write(omap[y][x])
      end

      IO.puts("")
    end

    omap
  end

  defp pad_top_bottom([head | _] = array) do
    width = String.split(head, "", trim: true) |> Enum.count()
    [String.duplicate(".", width)] ++ array ++ [String.duplicate(".", width)]
  end

  defp spaces_around(omap, x, y, c) do
    if(omap[y - 1][x] != c, do: 1, else: 0) +
      if(omap[y + 1][x] != c, do: 1, else: 0) +
      if(omap[y][x + 1] != c, do: 1, else: 0) +
      if omap[y][x - 1] != c, do: 1, else: 0
  end

  defp outside_tr(omap, x, y, c) do
    if omap[y - 1][x] != c and omap[y][x + 1] != c, do: 1, else: 0
  end

  defp outside_br(omap, x, y, c) do
    if omap[y][x + 1] != c and omap[y + 1][x] != c, do: 1, else: 0
  end

  defp outside_tl(omap, x, y, c) do
    if omap[y][x - 1] != c and omap[y - 1][x] != c, do: 1, else: 0
  end

  defp outside_bl(omap, x, y, c) do
    if omap[y][x - 1] != c and omap[y + 1][x] != c, do: 1, else: 0
  end

  defp inside_tr(omap, x, y, c) do
    if omap[y - 1][x] == c and omap[y][x + 1] == c and omap[y - 1][x + 1] != c, do: 1, else: 0
  end

  defp inside_br(omap, x, y, c) do
    if omap[y][x + 1] == c and omap[y + 1][x] == c and omap[y + 1][x + 1] != c, do: 1, else: 0
  end

  defp inside_tl(omap, x, y, c) do
    if omap[y - 1][x] == c and omap[y][x - 1] == c and omap[y - 1][x - 1] != c, do: 1, else: 0
  end

  defp inside_bl(omap, x, y, c) do
    if omap[y][x - 1] == c and omap[y + 1][x] == c and omap[y + 1][x - 1] != c, do: 1, else: 0
  end

  defp corners_around(omap, x, y, c) do
    outside_tr(omap, x, y, c) +
      outside_br(omap, x, y, c) +
      outside_tl(omap, x, y, c) +
      outside_bl(omap, x, y, c) +
      inside_tr(omap, x, y, c) +
      inside_br(omap, x, y, c) +
      inside_tl(omap, x, y, c) +
      inside_bl(omap, x, y, c)
  end

  defp build_region(omap, vmap, x, y, region) do
    region = Map.update!(region, :area, &(&1 + 1))
    region = Map.update!(region, :perimeter, &(&1 + spaces_around(omap, x, y, region.c)))
    region = Map.update!(region, :sides, &(&1 + corners_around(omap, x, y, region.c)))
    vmap = Arrays.replace(vmap, y, Arrays.replace(vmap[y], x, "."))

    {region, vmap} =
      if vmap[y - 1][x] == region.c,
        do: build_region(omap, vmap, x, y - 1, region),
        else: {region, vmap}

    {region, vmap} =
      if vmap[y + 1][x] == region.c,
        do: build_region(omap, vmap, x, y + 1, region),
        else: {region, vmap}

    {region, vmap} =
      if vmap[y][x - 1] == region.c,
        do: build_region(omap, vmap, x - 1, y, region),
        else: {region, vmap}

    {region, vmap} =
      if vmap[y][x + 1] == region.c,
        do: build_region(omap, vmap, x + 1, y, region),
        else: {region, vmap}

    {region, vmap}
  end

  defp find_regions(_omap, _vmap, acc, _x, y, _w, h) when y == h, do: acc

  defp find_regions(omap, vmap, acc, x, y, w, h) do
    {acc, vmap} =
      case vmap[y][x] do
        "." ->
          {acc, vmap}

        c ->
          {region, vmap} =
            build_region(omap, vmap, x, y, %{
              c: c,
              area: 0,
              perimeter: 0,
              sides: 0,
              apoint: {x, y}
            })

          {[region | acc], vmap}
      end

    if x == w - 1 do
      find_regions(omap, vmap, acc, 0, y + 1, w, h)
    else
      find_regions(omap, vmap, acc, x + 1, y, w, h)
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

  defp part1_time(omap) do
    find_regions(omap, omap, [], 0, 0, Arrays.size(omap[0]), Arrays.size(omap))
    |> calc_fencing()
  end

  defp part1(omap) do
    {time, count} = :timer.tc(&part1_time/1, [omap])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp part2_time(omap) do
    find_regions(omap, omap, [], 0, 0, Arrays.size(omap[0]), Arrays.size(omap))
    |> calc_fencing_sides()
  end

  defp part2(omap) do
    {time, count} = :timer.tc(&part2_time/1, [omap])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    omap = read_input()
    part1(omap)
    part2(omap)
  end
end
