defmodule Speed do

  @acceleration 500

  defstruct current: 75000, target: 75000

  def next_speed(%Speed{current: current, target: target} = speed) do
    cond do
      current == target -> speed
      current < target -> %{speed | current: current + @acceleration}
      current > target -> %{speed | current: current - @acceleration}
    end
  end

end
