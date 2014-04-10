defmodule Restnull.TableManager do
  use GenServer.Behaviour

  def start_link() do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def init(_state) do
    {:ok, _state}
  end

  def table(table_name) when is_binary(table_name), do: binary_to_atom(table_name) |> table
  def table(table_name) when is_atom(table_name) do
    if table_exists?(table_name) do
      table_name
    else
      :gen_server.call(__MODULE__, {:create_table, table_name})
    end
  end

  def table_exists?(table_name) when is_binary(table_name), do: binary_to_atom(table_name) |> table_exists?
  def table_exists?(table_name) when is_atom(table_name) do
    :ets.info(table_name) != :undefined
  end

  def handle_call({:create_table, table_name}, _from, _state) do
    tid = :ets.new(table_name, [:public, :named_table])
    {:reply, tid, _state}
  end
end
