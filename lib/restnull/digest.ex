defmodule Restnull.Digest do
  def hex_sha(value) do
    :crypto.hash(:sha, value) |> bin_to_hexstring
  end

  def bin_to_hexstring(<<value :: [size(160), big, unsigned, integer]>>) do
    :io_lib.format("~40.16.0b", [value]) |>
    :lists.flatten |>
    iolist_to_binary
  end
end
