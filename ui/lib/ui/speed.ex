defmodule Speed do

  @pwm_neutral 75000
  @pwm_max 100000
  @pwm_min 50000

  @acceleration 500

  defstruct current: @pwm_neutral, target: @pwm_neutral, cur: :neutral, neg4: @pwm_min, neg3: 55000, neg2: 60000, neg1: 65000, neutral: @pwm_neutral, pos1: 85000, pos2: 90000, pos3: 95000, pos4: @pwm_max

  def next_speed(%Speed{current: current, target: target} = speed) when is_map(speed) do
    cond do
      current == target -> speed
      current < target -> %{speed | current: current + @acceleration}
      current > target -> %{speed | current: current - @acceleration}
    end
  end

  def pwm_from_percent(percent) when percent == 0 do
    0
  end
  def pwm_from_percent(percent) do
    @pwm_neutral + percent * 250
  end

  def percent_from_pwm(pwm) do
    cond do
      pwm > @pwm_neutral -> (pwm - @pwm_neutral) / 250
      pwm < @pwm_neutral -> -(@pwm_neutral - pwm) / 250
      pwm == @pwm_neutral -> 0
    end
  end

  defp next_atom(cur) do
    case cur do
      :neg4 -> :neg3
      :neg3 -> :neg2
      :neg2 -> :neg1
      :neg1 -> :neutral
      :neutral -> :pos1
      :pos1-> :pos2
      :pos2 -> :pos3
      :pos3 -> :pos4
      _ -> cur
    end
  end

  defp prev_atom(cur)do
    case cur do
       :pos4 -> :pos3
       :pos3 -> :pos2
       :pos2 -> :pos1
       :pos1 -> :neutral
       :neutral -> :neg1
       :neg1 -> :neg2
       :neg2 -> :neg3
       :neg3 -> :neg4
       _ -> cur
    end
  end

  def next_target(%Speed{cur: cur} = speed) do
    next = next_atom(cur)
    %{speed | cur: next, target: Map.get(speed, next)}
  end

  def prev_target(%Speed{cur: cur} = speed) do
    prev = prev_atom(cur)
    %{speed | cur: prev, target: Map.get(speed, prev)}
  end

  def stop(%Speed{} = speed) do
    %{speed | cur: :neutral, target: @pwm_neutral}
  end

end
