defmodule Babysitting.Utils do
  def atomize_keys(map) do
    for {k, v} <- map, into: %{}, do: {String.to_existing_atom(k), v}
  end
end
