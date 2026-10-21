defmodule Fluxter.Conn.GenUdp do
  @moduledoc false

  use Fluxter.Conn

  alias Fluxter.Packet
  require Logger

  defstruct [:sock, :addr, :port, :prefix]

  @impl Fluxter.Conn
  def new(host, port, prefix) when is_binary(host) do
    new(String.to_charlist(host), port, prefix)
  end

  def new(host, port, prefix) when is_list(host) or is_tuple(host) do
    {:ok, addr} = :inet.getaddr(host, :inet)
    %__MODULE__{addr: addr, port: port, prefix: prefix}
  end

  @impl Fluxter.Conn
  def start_link(%__MODULE__{} = conn, worker) do
    GenServer.start_link(__MODULE__, conn, name: worker)
  end

  @impl Fluxter.Conn
  def write(worker, name, tags, fields, timestamp)
      when (is_binary(name) or is_list(name)) and is_list(tags) and is_list(fields) do
    GenServer.cast(worker, {:write, name, tags, fields, timestamp})
  end

  @impl GenServer
  def init(conn) do
    {:ok, sock} = :gen_udp.open(0, active: false)
    {:ok, %{conn | sock: sock}}
  end

  @impl GenServer
  def handle_cast({:write, name, tags, fields, timestamp}, conn) do
    packet = Packet.build(conn.prefix, name, tags, fields, timestamp)

    case :gen_udp.send(conn.sock, conn.addr, conn.port, packet) do
      :ok ->
        {:noreply, conn}

      {:error, reason} ->
        Logger.warning("fluxter: failed to send metric: #{:inet.format_error(reason)}; reopening socket")
        :gen_udp.close(conn.sock)
        {:ok, sock} = :gen_udp.open(0, active: false)
        {:noreply, %{conn | sock: sock}}
    end
  end
end
