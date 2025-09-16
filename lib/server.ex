defmodule Craf.Server do
  import Craf.Read
  require Logger

  def run do
    {:ok, socket} =
      :gen_tcp.listen(25565, [:binary, packet: :raw, active: false, reuseaddr: true])

    loop_accept(socket)
  end

  def loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(Craf.TaskSupervisor, fn ->
        handle_client(client, :handshake)
      end)

    :ok = :gen_tcp.controlling_process(client, pid)

    loop_accept(socket)
  end

  def handle_client(client, state) do
    {:ok, length} = read_varint(client)
    {:ok, packet_id} = read_varint(client)

    state = handle_packet(client, state, length, packet_id)

    handle_client(client, state)
  end

  def handle_packet(client, :handshake, _length, 0x00) do
    {:ok, protocol_version} = read_varint(client)
    {:ok, address} = read_string(client)
    {:ok, port} = read_uint16(client)
    {:ok, intent} = read_varint(client)

    Logger.debug(
      "received handshake packet with protocol version #{protocol_version}, address #{address}, port #{port}, intent #{intent}"
    )

    case intent do
      1 -> :status
      2 -> :login
      _ -> raise "unhandled intent #{intent}"
    end
  end

  def handle_packet(client, :status, _length, 0x00) do
    Logger.debug("received status request")

    :status
  end

  def handle_packet(_client, state, length, packet_id) do
    Logger.warning("unhandled packet #{packet_id} with length #{length} in state #{state}")

    state
  end
end
