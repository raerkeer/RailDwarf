defmodule Convert do
  @minute 60
  @hour   @minute*60
  @divisor [@hour, @minute, 1]

  def sec_to_str(sec) do
    {_, [s, m, h]} =
        Enum.reduce(@divisor, {sec,[]}, fn divisor,{n,acc} ->
          {rem(n,divisor), [div(n,divisor) | acc]}
        end)
    ["#{h}", "#{m}", "#{s}"]
    |> Enum.reject(fn str -> String.starts_with?(str, "0") end)
    |> Enum.join(":")
  end
end
