defmodule RestnullTest do
  use ExUnit.Case, async: true

  defrecord Response, [version: nil, code: nil, reason: nil, headers: nil, body: nil, body_decode: nil]

  setup_all do
    :application.start(:inets)
  end

  test "GET not existing collection" do
    res = req("http://localhost:8080/no_collection")
    assert(res.body_decode == [])
  end

  test "POST to a collection" do
    payload_json = JSEX.encode!("bar": "baz")
    res = req(:post, "http://localhost:8080/post_collection", payload_json)
    assert(res.code == 303)
    location = res.headers['location'] |> to_string
    assert(Regex.match?(~r/http:\/\/localhost:8080\/post_collection\/[a-f0-9]{40}/, location))

    res2 = req(location)
    assert(res2.body_decode == [{"bar", "baz"}])
  end

  test "GET from populated collection" do
    req(:post, "http://localhost:8080/populated_collection", JSEX.encode!("bar": "baz"))
    req(:post, "http://localhost:8080/populated_collection", JSEX.encode!("bor": "boz"))

    res = req("http://localhost:8080/populated_collection")
    assert(res.code == 200)
    assert(res.body_decode == [ [{"bor", "boz"}], [{"bar", "baz"}]])
  end

  test "PUT and GET a named resource" do
    payload_json = JSEX.encode!("bar": "baz")
    res = req(:put, "http://localhost:8080/put_collection/foobar", payload_json)

    assert(res.code == 201)

    res2 = req("http://localhost:8080/put_collection/foobar")
    assert(res2.code == 200)
    assert(res2.body_decode == [{"bar", "baz"}])
  end

  test "GET named resource from non existing collection" do
    res = req("http://localhost:8080/non_existing/non_existing")
    assert(res.code == 404)
  end

  test "GET non existing named resorce from existing collection" do
    payload_json = JSEX.encode!("bar": "baz")
    res = req(:put, "http://localhost:8080/existing/foobar", payload_json)

    res2 = req("http://localhost:8080/existing/bzzz")
    assert(res2.code == 404)
  end

  defp req(url) do
    req(:get, url, nil)
  end

  defp req(method, url, payload) do
    url = to_char_list(url)

    request = if payload do
      {url, [], 'application/json', payload}
    else
      {url, []}
    end

    {:ok, {{version, code, reason}, headers, body}} = :httpc.request(method,request, [autoredirect: false], [])
    body = to_string(body)
    body_decode = case JSEX.decode(body) do
      {:ok, term} -> term
      {:error, _reason} -> nil
    end
    Response.new(version: version, code: code, reason: reason, headers: headers, body: body, body_decode: body_decode)
  end
end
