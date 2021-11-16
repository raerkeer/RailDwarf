defmodule Loco do
  use GenServer

  # Client
  def start_link(_default) do
    GenServer.start_link(__MODULE__, 75000, name: LocoServer)
  end

  def set(action) do
    GenServer.cast(LocoServer, action)
  end

  def get() do
    GenServer.call(LocoServer, :get_speed)
  end

  # Server Callbacks
  @impl true
  def init(speed) do
    Pigpiox.Pwm.hardware_pwm(12, 50, speed)
    {:ok, speed}
  end

  @impl true
  def handle_call(:get_speed, _from, speed) do
    percent =
    case speed do
      75000 -> 0
      x when x < 75000 -> (75000 - x) / 250
      x when x > 75000 -> -(x - 75000) / 250
    end
    {:reply, percent, speed}
  end

  #range 50000 - 75000 - 100000 (delta 25000)
  @impl true
  def handle_cast(:acc, old_speed) do
    new_speed = old_speed - 5000
    Pigpiox.Pwm.hardware_pwm(12, 50, new_speed)
    {:noreply, new_speed}
  end

  @impl true
  def handle_cast(:dec, old_speed) do
    new_speed = old_speed + 5000
    Pigpiox.Pwm.hardware_pwm(12, 50, new_speed)
    {:noreply, new_speed}
  end

  @impl true
  def handle_cast(:stop, _old_speed) do
    new_speed = 75000
    Pigpiox.Pwm.hardware_pwm(12, 50, new_speed)
    {:noreply, new_speed}
  end
end
