defmodule UiWeb.PageLive do
  use UiWeb, :live_view

  @refresh_interval_ms 500
  @configfile "/data/settings"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    settings =
    case File.exists?(@configfile) do
      true ->
        File.read!(@configfile)
      false ->
        File.write(@configfile, "false")
        "false"
    end

    reverse =
    case settings do
      "false" -> false
      "true" -> true
    end

    socket =
      socket
      |> assign(current_runtime: System.monotonic_time(:second) |> Convert.sec_to_str)
      |> assign(speed: LocoSpeed.get)
      |> assign(show_modal: false)
      |> assign(reverse: reverse)
      |> assign(speed1: 40)
      |> assign(speed2: 60)
      |> assign(speed3: 80)
      |> assign(speed4: 100)

    if connected?(socket) do
      :timer.send_interval(@refresh_interval_ms, self(), :tick)
    end

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, socket) do
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
    case socket.assigns.reverse do
      false -> LocoSpeed.set(:acc)
      true -> LocoSpeed.set(:dec)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("dec", _value, socket) do
    case socket.assigns.reverse do
      false -> LocoSpeed.set(:dec)
      true -> LocoSpeed.set(:acc)
    end
    {:noreply, socket}
  end

  def handle_event("toggle-modal", _, socket) do
    {:noreply, update(socket, :show_modal, &(!&1))}
  end

  def handle_event("reverse", _, socket) do
    reverse = !socket.assigns.reverse
    File.write(@configfile, Kernel.inspect(reverse))
    {:noreply, assign(socket, :reverse, reverse)}
  end

  def handle_event("speed", %{"speed1"=>speed1, "speed2"=>speed2, "speed3"=>speed3, "speed4"=>speed4}, socket) do

    socket =
      socket
      |> assign(:speed1, speed1)
      |> assign(:speed2, speed2)
      |> assign(:speed3, speed3)
      |> assign(:speed4, speed4)

    {:noreply, socket}
  end

end
