defmodule UiWeb.PageLive do
  use UiWeb, :live_view

  @refresh_interval_ms 1000

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(current_runtime: System.monotonic_time(:second) |> Convert.sec_to_str)
      |> assign(speed: LocoSpeed.get)

    if connected?(socket) do
      schedule_refresh()
    end

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, socket) do
    schedule_refresh()
    socket =
      socket
      |> assign(current_runtime: System.monotonic_time(:second) |> Convert.sec_to_str)
      |> assign(speed: LocoSpeed.get)

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _value, socket) do
    LocoSpeed.set(:stop)
    {:noreply, socket}
  end

  @impl true
  def handle_event("inc", _value, socket) do
    LocoSpeed.set(:dec) # TODO invert or make configurable
    {:noreply, socket}
  end

  @impl true
  def handle_event("dec", _value, socket) do
    LocoSpeed.set(:acc)
    {:noreply, socket}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :tick, @refresh_interval_ms)
  end

end
