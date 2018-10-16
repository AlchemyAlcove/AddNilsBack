defmodule ParamUtils do
  @moduledoc """
  ParamUtils adds nils back to changesets.
  """

  @doc """
  Params library removes nil and empty strings via changeset.
  For update actions the user may actually want to save a nil value.
  original param is used to pass the original data from user including the nils and empty strings.
  last param is a list of user params that could be nil or empty string.

  ## Examples

      iex> ParamUtils.add_nils_back({:ok, %{original_params: %{}, params: %{}}})
      {:ok, %{original_params: %{}, params: %{}}}
      iex> ParamUtils.add_nils_back({:ok, %{original_params: %{"colors" => "Orange", "image" => nil}, params: %{colors: "Orange"}}})
      {:ok, %{original_params: %{"colors" => "Orange", "image" => nil}, params: %{colors: "Orange", image: nil}}}
  """
  @spec add_nils_back({:ok, %{original_params: List.t, params: List.t}} | {:error, Map.t}) :: {:ok, Map.t} | {:error, Map.t}
  def add_nils_back({:error, _} = msg), do: msg
  def add_nils_back({:ok, %{original_params: original}} = msg), do: add_nils_back(msg, Map.keys(original))
  def add_nils_back({:ok, _}), do: {:error, "Original params are required"}
  def add_nils_back(msg, []), do: msg
  def add_nils_back({:ok, %{original_params: original, params: params} = data} = msg, [item | list]) do
    if Map.has_key?(original, item) do
      case Map.get(original, item) do
        nil -> add_nils_back({:ok, data |> Map.put(:params, params |> Map.put(String.to_atom(item), nil))}, list)
        "" -> add_nils_back({:ok, data |> Map.put(:params, params |> Map.put(String.to_atom(item), nil))}, list)
        _ -> add_nils_back(msg, list)
      end
    else
      add_nils_back(msg, list)
    end
  end
end
