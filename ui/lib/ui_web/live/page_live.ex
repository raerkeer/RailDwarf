defmodule UiWeb.PageLive do
  use UiWeb, :live_view

  @refresh_interval_ms 500

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    settings = LocoConfig.load()
    %LocoConfig{name: name, reverse: reverse} = settings

    LocoSpeed.set_speeds(settings)

    percents = LocoConfig.get_percent(settings)

    socket =
      socket
      |> assign(current_runtime: System.monotonic_time(:second) |> Convert.sec_to_str)
      |> assign(speed: LocoSpeed.get)
      |> assign(show_modal: false)
      |> assign(reverse: reverse)
      |> assign(name: name)
      |> assign(speed1: percents.speed1)
      |> assign(speed2: percents.speed2)
      |> assign(speed3: percents.speed3)
      |> assign(speed4: percents.speed4)

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
    settings = %{LocoConfig.load() | reverse: reverse}
    LocoConfig.write(settings)
    {:noreply, assign(socket, :reverse, reverse)}
  end

  def handle_event("name", %{"name" => name}, socket) do
    settings = %{LocoConfig.load() | name: name}
    LocoConfig.write(settings)
    {:noreply, assign(socket, :name, name)}
  end

  defp str_to_int(val) do
    case Integer.parse(val) do
      :error -> 0
      {x, _} -> x
    end
  end

  def handle_event("speed", %{"speed1"=>speed1, "speed2"=>speed2, "speed3"=>speed3, "speed4"=>speed4}, socket) do
    s1 = str_to_int(speed1)
    s2 = str_to_int(speed2)
    s3 = str_to_int(speed3)
    s4 = str_to_int(speed4)
    socket =
      socket
      |> assign(:speed1, s1)
      |> assign(:speed2, s2)
      |> assign(:speed3, s3)
      |> assign(:speed4, s4)

      settings = LocoConfig.set_percent(s1, s2, s3, s4)
      LocoSpeed.set_speeds(settings)
      LocoConfig.write(settings)
    {:noreply, socket}
  end

end
