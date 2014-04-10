defmodule Restnull.CollectionHandler do
  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET", "POST"], req, state}
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

    {:ok, body, req} = :cowboy_req.body(req)
    payload = JSEX.decode!(body)

    key = Restnull.Digest.hex_sha(body)

    :ets.insert(table, {key, payload})
    {host_url, req} = :cowboy_req.host_url(req)
    {{true, "#{host_url}/#{table}/#{key}"}, req, state}
  end

  def content_types_provided(req, state) do
    {[
      { {"application", "json", [] }, :find_collection}
    ], req, state}
  end

  def find_collection(req, state) do
    {collection_id, req} = :cowboy_req.binding(:collection_id, req)
    table = Restnull.TableManager.table(collection_id)
    all = :ets.tab2list(table) |>
      Enum.map(fn({key, value}) -> value end) |>
      JSEX.encode!
    {all, req, state}
  end

end
