defmodule D14 do
  require Integer
  @aoc_year "2024"
  @aoc_day __MODULE__ |> to_string() |> String.slice(-2..-1)
  # 0 is the file itself, need w/h of the tiles (101x103)
  # 1 is the example (11x7)
  @content 0
  @width 101
  @height 103
  @horizontal_middle div(@width, 2)
  @vertical_middle div(@height, 2)
  @debug false

  def read_input do
    content = %{
      0 => File.read!("./lib/#{@aoc_day}.txt"),
      1 => """
      p=0,4 v=3,-3
      p=6,3 v=-1,-3
      p=10,3 v=-1,2
      p=2,0 v=2,-1
      p=0,0 v=1,3
      p=3,0 v=-2,-2
      p=7,6 v=-1,-3
      p=3,0 v=-1,-2
      p=9,3 v=2,3
      p=7,3 v=-1,2
      p=2,4 v=2,-3
      p=9,5 v=-3,-3
      """
    }

    robots =
      content[@content]
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [[_, x], [_, y], [_, vx], [_, vy], [_, _]] = Regex.scan(~r/[^-\d]*([-\d]*)/, line)

        %{
          x: String.to_integer(x),
          y: String.to_integer(y),
          vx: String.to_integer(vx),
          vy: String.to_integer(vy)
        }
      end)

    if @debug, do: print_grid(robots), else: robots
  end

  defp print_grid(robots) do
    str = get_grid_str(robots)
    IO.puts(str)
    robots
  end

  defp get_grid_str(robots) do
    mapset =
      Enum.reduce(robots, MapSet.new(), fn robot, acc ->
        MapSet.put(acc, {robot.x, robot.y})
      end)

    lines =
      Enum.reduce(0..(@height - 1), [], fn y, acc ->
        [
          Enum.reduce(0..(@width - 1), [], fn x, acc ->
            if MapSet.member?(mapset, {x, y}) do
              ["*" | acc]
            else
              [" " | acc]
            end
          end)
          | acc
        ]
      end)

    Enum.reverse(lines) |> Enum.map(&Enum.join(Enum.reverse(&1))) |> Enum.join("\n")
  end

  defp move_robot(robot, seconds) do
    %{
      robot
      | x: Integer.mod(robot.x + robot.vx * seconds, @width),
        y: Integer.mod(robot.y + robot.vy * seconds, @height)
    }
  end

  defp move_robots(robots, seconds) do
    Enum.map(robots, fn robot -> move_robot(robot, seconds) end)
  end

  defp robots_per_quadrant(robots) do
    Enum.reduce(
      robots,
      %{{:left, :top} => 0, {:right, :top} => 0, {:left, :bottom} => 0, {:right, :bottom} => 0},
      fn robot, acc ->
        x = robot.x
        y = robot.y

        if x == @horizontal_middle or y == @vertical_middle do
          acc
        else
          key =
            if x < @horizontal_middle do
              if y < @vertical_middle, do: {:left, :bottom}, else: {:left, :top}
            else
              if y < @vertical_middle, do: {:right, :bottom}, else: {:right, :top}
            end

          Map.update(acc, key, 1, &(&1 + 1))
        end
      end
    )
  end

  defp part1_time(robots),
    do:
      move_robots(robots, 100)
      |> robots_per_quadrant()
      |> Enum.reduce(1, fn {_, count}, acc -> acc * count end)

  defp part1(robots) do
    {time, count} = :timer.tc(&part1_time/1, [robots])
    IO.puts("Part 1: #{count} in #{time / 1000}ms")
  end

  defp is_christmas_tree?(robots) do
    grid = get_grid_str(robots)
    String.contains?(grid, "****************")
  end

  defp part2_time(robots) do
    Enum.reduce_while(1..1_000_000_000_000, 0, fn seconds, _ ->
      if is_christmas_tree?(move_robots(robots, seconds)) do
        {:halt, seconds}
      else
        {:cont, 0}
      end
    end)
  end

  defp part2(robots) do
    {time, count} = :timer.tc(&part2_time/1, [robots])
    IO.puts("Part 2: #{count} in #{time / 1000}ms")
  end

  def run() do
    IO.puts("AOC #{@aoc_year} Day #{@aoc_day} Content #{@content}")
    robots = read_input()
    part1(robots)
    part2(robots)
  end
end
