defmodule Firmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    name_loaded = LocoConfig.load().name
    name =
      cond do
        String.length(name_loaded) > 0 -> name_loaded
        true -> "#{Enum.random(1000..9999)}"
      end

    VintageNet.configure("wlan0",%{
      dhcpd: %{
        end: {192, 168, 0, 254},
        max_leases: 235,
        options: %{
          dns: [{192, 168, 0, 1}],
          domain: "raildwarf.local",
          router: [{192, 168, 0, 1}],
          search: ["raildwarf.local"],
          subnet: {255, 255, 255, 0}
        },
        start: {192, 168, 0, 20}
      },
      dnsd: %{
        records: [
          {"raildwarf.local", {192, 168, 0, 1}},
          {"*", {192, 168, 0, 1}}
        ]
      },
      ipv4: %{address: {192, 168, 0, 1}, method: :static, prefix_length: 24},
      type: VintageNetWiFi,
      vintage_net_wifi: %{
        networks: [%{key_mgmt: :none, mode: :ap, ssid: "raildwarf_"<>name}]
      }
    })

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Firmware.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Firmware.Worker.start_link(arg)
        # {Firmware.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Firmware.Worker.start_link(arg)
      # {Firmware.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Firmware.Worker.start_link(arg)
      # {Firmware.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:firmware, :target)
  end
end
