defmodule LocoSpeed do
  use GenServer

  @gpio_pin 12
  @pwm_frequency 50
  @pwm_neutral 75000
  @pwm_max 100000
  @pwm_min 50000

  # Client
  def start_link(_default) do
    GenServer.start_link(__MODULE__, @pwm_neutral, name: LocoSpeedServer)
  end

  def set(action) do
    GenServer.cast(LocoSpeedServer, action)
  end

  def get do
    GenServer.call(LocoSpeedServer, :get_speed)
  end

  # Server Callbacks
  @impl true
  def init(speed) do
    set_pwm(speed)
    {:ok, speed}
  end

  @impl true
  def handle_call(:get_speed, _from, speed) do
    percent =
    cond do
      speed > @pwm_neutral -> (@pwm_neutral - speed) / 250
      speed < @pwm_neutral -> -(speed - @pwm_neutral) / 250
      speed == @pwm_neutral -> 0
    end

    {:reply, percent, speed}
  end

  @impl true
  def handle_cast(:acc, old_speed) when old_speed == @pwm_max do
    {:noreply, old_speed}
  end
  def handle_cast(:acc, old_speed) when old_speed == @pwm_neutral do
    new_speed = old_speed + 10000 # because of the non linear esc...
    set_pwm(new_speed)
    {:noreply, new_speed}
  end
  def handle_cast(:acc, old_speed) do
    new_speed = old_speed + 5000
    set_pwm(new_speed)
    {:noreply, new_speed}
  end

  @impl true
  def handle_cast(:dec, old_speed) when old_speed ==  @pwm_min do
    {:noreply, old_speed}
  end
  def handle_cast(:dec, old_speed) when old_speed == @pwm_neutral do
    new_speed = old_speed - 10000
    set_pwm(new_speed)
    {:noreply, new_speed}
  end
  def handle_cast(:dec, old_speed) do
    new_speed = old_speed - 5000
    set_pwm(new_speed)
    {:noreply, new_speed}
  end

  @impl true
  def handle_cast(:stop, old_speed) do
    schedule_speed(@pwm_neutral)
    {:noreply, old_speed}
  end

  @impl true
  def handle_info({:speed, target_speed}, old_speed) when target_speed == old_speed do
    {:noreply, target_speed}
  end
  def handle_info({:speed, target_speed}, old_speed) do
    new_speed =
    cond do
      target_speed > old_speed -> old_speed + 500
      target_speed < old_speed -> old_speed - 500
    end

    set_pwm(new_speed)

    schedule_speed(target_speed)

    {:noreply, new_speed}
  end

  defp schedule_speed(target_speed) do
    Process.send_after(self(), {:speed, target_speed}, 20)
  end

  defp set_pwm(level) do
    Pigpiox.Pwm.hardware_pwm(@gpio_pin, @pwm_frequency, level)
  end

end
