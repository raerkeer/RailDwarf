defmodule Loco do
  use GenServer

  @gpio 12

  # Client
  def start_link(_default) do
    GenServer.start_link(__MODULE__, 75000, name: LocoSpeedServer)
  end

  def set(action) do
    GenServer.cast(LocoSpeedServer, action)
  end

  def get() do
    GenServer.call(LocoSpeedServer, :get_speed)
  end

  # Server Callbacks
  @impl true
  def init(speed) do
    Pigpiox.Pwm.hardware_pwm(@gpio, 50, speed)
    {:ok, speed}
  end

  @impl true
  def handle_call(:get_speed, _from, speed) do
    percent =
    cond do
      speed > 75000 -> (75000 - speed) / 250
      speed < 75000 -> -(speed - 75000) / 250
      speed == 75000 -> 0
    end

    {:reply, percent, speed}
  end

  #range 50000 - 75000 - 100000 (delta 25000)
  @impl true
  def handle_cast(:acc, old_speed) do
    new_speed = old_speed + 5000
    Pigpiox.Pwm.hardware_pwm(@gpio, 50, new_speed)
    {:noreply, new_speed}
  end

  @impl true
  def handle_cast(:dec, old_speed) do
    new_speed = old_speed - 5000
    Pigpiox.Pwm.hardware_pwm(@gpio, 50, new_speed)
    {:noreply, new_speed}
  end

  @impl true
  def handle_cast(:stop, old_speed) do
    new_speed = 75000
    schedule_speed(new_speed)
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

    Pigpiox.Pwm.hardware_pwm(12, 50, new_speed)

    # Reschedule once more
    schedule_speed(target_speed)

    {:noreply, new_speed}
  end
# TODO target_speed muss im state sein
  defp schedule_speed(target_speed) do
    # We schedule the work to happen in 2 hours (written in milliseconds).
    # Alternatively, one might write :timer.hours(2)
    Process.send_after(self(), {:speed, target_speed}, 20)
  end
end
