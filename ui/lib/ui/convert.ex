defmodule Convert do
  @minute 60
  @hour   @minute*60
  @divisor [@hour, @minute, 1]

  def sec_to_str(sec) do
    "#{div(sec,60)} min"
  end
end
