defmodule ParamUtils do
  @moduledoc """
  ParamUtils adds nils back to changesets.
  """

  @doc """
  Params library removes nil and empty strings via changeset.
  For update actions the user may actually want to save a nil value.
  original param is used to pass the original data from user including the nils and empty strings.
  last param is a list of user params that could be nil or empty string.
  """
  def add_nils_back(msg, _original, []), do: msg
  def add_nils_back({:ok, %{params: params} = data} = msg, original, [item | list]) do
    if Map.has_key?(original, item) do
      case Map.get(original, item) do
        nil -> add_nils_back({:ok, data |> Map.put(:params, params |> Map.put(String.to_atom(item), nil))}, original, list)
        "" -> add_nils_back({:ok, data |> Map.put(:params, params |> Map.put(String.to_atom(item), nil))}, original, list)
        _ -> add_nils_back(msg, original, list)
      end
    else
      add_nils_back(msg, original, list)
    end
  end
end
