defmodule Restnull.ResourceHandler do
  defrecord State, [resource: nil, collection_id: nil, resource_id: nil]

  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def rest_init(req, _opts) do
    {:ok, req, State.new()}
  end

  def resource_exists(req, state) do
    {collection_id, req} = :cowboy_req.binding(:collection_id, req)
    {resource_id, req} = :cowboy_req.binding(:resource_id, req)

    state = state.update(collection_id: collection_id, resource_id: resource_id)

    resource = if Restnull.TableManager.table_exists?(collection_id) do
      case :ets.lookup(binary_to_atom(collection_id), resource_id) do
        [] -> nil # not found
        [{resource_id, resource}] -> resource
      end
    end
    state = state.resource(resource)
    {state.resource != nil, req, state}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "DELETE"], req, state}
  end

  def content_types_accepted(req, state) do
    acceptors = [
      {{"application", "json", :*}, :create_resource}
    ]
    {acceptors, req, state}
  end

  def create_resource(req, state) do
    {collection_id, req} = :cowboy_req.binding(:collection_id, req)
    table = Restnull.TableManager.table(collection_id)

    {resource_id, req} = :cowboy_req.binding(:resource_id, req)

    {:ok, body, req} = :cowboy_req.body(req)
    payload = JSEX.decode!(body)

    key = resource_id

    :ets.insert(table, {key, payload})
    {true, req, state}
  end

  def content_types_provided(req, state) do
    {[
      { {"application", "json", [] }, :find_resource}
    ], req, state}
  end

  def find_resource(req, state) do
    body = state.resource |> JSEX.encode!
    {body, req, state}
  end

end
