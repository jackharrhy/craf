defmodule Craf.Read do
  import Bitwise

  def read_varint(socket) do
    read_varint(socket, 0, 0)
  end

  defp read_varint(_socket, _value, 5) do
    {:error, :varint_too_long}
  end

  defp read_varint(socket, value, bytes_read) do
    case :gen_tcp.recv(socket, 1) do
      {:ok, <<byte>>} ->
        part = byte &&& 0b01111111
        value = value ||| part <<< (7 * bytes_read)

        if (byte &&& 0b10000000) == 0 do
          {:ok, value}
        else
          read_varint(socket, value, bytes_read + 1)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def read_string(socket) do
    with {:ok, length} <- read_varint(socket),
         {:ok, data} <- :gen_tcp.recv(socket, length) do
      {:ok, data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def read_uint16(socket) do
    case :gen_tcp.recv(socket, 2) do
      {:ok, <<byte1, byte2>>} ->
        value = byte1 <<< 8 ||| byte2
        {:ok, value}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
