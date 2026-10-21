defmodule Fluxter.Conn do
  @moduledoc """
  Connection behaviour
  """

  defmacro __using__(_opts) do
    quote do
      use GenServer
      @behaviour Fluxter.Conn
    end
  end

  @callback new(
    host :: binary(),
    port :: integer(),
    prefix :: binary()
  ) :: struct()

  @callback start_link(struct(), name :: atom()) :: {:ok, pid()}

  @callback write(
    worker :: __MODULE__,
    name :: binary() | charlist(),
    tags :: [{String.Chars.t(), String.Chars.t()}],
    fields :: [{String.Chars.t(), String.Chars.t()}]
  ) :: :ok
end
