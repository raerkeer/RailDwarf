defmodule LocoConfig do
  @pwm_max 100000
  @pwm_min 50000

  @configfile "/data/settings"

  defstruct name: "", reverse: false, neg4: @pwm_min, neg3: 55000, neg2: 60000, neg1: 65000, pos1: 85000, pos2: 90000, pos3: 95000, pos4: @pwm_max

  def load do
      case File.exists?(@configfile) do
        true ->
          File.read!(@configfile) |> :erlang.binary_to_term()
        false ->
          %LocoConfig{}
      end
  end

  def write(settings) do
    File.write(@configfile, :erlang.term_to_binary(settings))
  end

  def set_percent(speed1, speed2, speed3, speed4) do
    pos1 = Speed.pwm_from_percent(speed1)
    pos2 = Speed.pwm_from_percent(speed2)
    pos3 = Speed.pwm_from_percent(speed3)
    pos4 = Speed.pwm_from_percent(speed4)
    neg1 = Speed.pwm_from_percent(-speed1)
    neg2 = Speed.pwm_from_percent(-speed2)
    neg3 = Speed.pwm_from_percent(-speed3)
    neg4 = Speed.pwm_from_percent(-speed4)

    settings = %{load() | neg4: neg4, neg3: neg3, neg2: neg2, neg1: neg1, pos1: pos1, pos2: pos2, pos3: pos3, pos4: pos4}

    write(settings)
    settings
  end

  def get_percent(%LocoConfig{pos1: pos1, pos2: pos2, pos3: pos3, pos4: pos4}) do
    p1 = Speed.percent_from_pwm(pos1)
    p2 = Speed.percent_from_pwm(pos2)
    p3 = Speed.percent_from_pwm(pos3)
    p4 = Speed.percent_from_pwm(pos4)
    %{speed1: p1, speed2: p2, speed3: p3, speed4: p4}
  end

end
