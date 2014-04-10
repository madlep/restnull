defmodule Restnull do
  use Application.Behaviour

  def main(_args) do
    :timer.sleep(:infinity)
  end

  def start(_type, _args) do
    {:ok, _} = start_cowboy()
    Restnull.Supervisor.start_link()
  end

  def start_cowboy() do
    routes = [
      {"/:collection_id", Restnull.CollectionHandler, []},
      {"/:collection_id/:resource_id", Restnull.ResourceHandler, []}
    ]

    dispatch = [ {:_, routes } ] |> :cowboy_router.compile

    :cowboy.start_http( :http, 10, [port: 8080], [env: [dispatch: dispatch]])
  end
end
