defmodule Fluxter.Pool do
  @moduledoc """
  Pool persistent_term storage
  """

  @spec store(atom(), module(), [atom()]) :: :ok
  def store(pool, conn_mod, worker_names) when is_list(worker_names) do
    :persistent_term.put(key(pool), {conn_mod, worker_names})
  end

  @spec state(atom()) :: {module(), [atom()]}
  def state(pool) do
    :persistent_term.get(key(pool))
  end

  @spec workers(atom()) :: [atom()]
  def workers(pool) do
    {_conn_mod, worker_names} = state(pool)
    worker_names
  end

  defp key(pool), do: {:fluxter_pool, pool}
end
