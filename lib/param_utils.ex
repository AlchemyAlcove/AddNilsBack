defmodule ParamUtils do
  @moduledoc """
  ParamUtils provides functions for converting user input into accepted internal data.
  """

  import OK, only: ["~>>": 2]

  @doc since: "0.1.0"
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

  @doc since: "0.2.0"
  @spec assign_changeset({:ok, Map.t} | {:error, Map.t}, Function.t) :: {:ok, Map.t} | {:error, Map.t}
  def assign_changeset({:ok, map}, changeset), do: {:ok, map |> Map.put(:changeset_function, changeset)}
  def assign_changeset({:error, _map} = error, _changeset), do: error

  @doc since: "0.2.0"
  @spec assign_data({:ok, Map.t} | {:error, Map.t}, Map.t) :: {:ok, Map.t} | {:error, Map.t}
  def assign_data({:ok, map}, data), do: {:ok, map |> Map.put(:original_data, data)}
  def assign_data({:error, _map} = error, _data), do: error

  @doc since: "0.2.0"
  @spec assign_original({:ok, Map.t} | {:error, Map.t}, Function.t) :: {:ok, Map.t} | {:error, Map.t}
  def assign_original({:ok, map}, params), do: {:ok, map |> Map.put(:original_params, params)}
  def assign_original({:error, _map} = error, _params), do: error
 
  @doc since: "0.2.0"
  @spec convert_params(%{changeset: Function.t, data: Map.t, params: Map.t}) :: {:ok, Map.t} | {:error, Map.t}
  def convert_params(%{changeset: changeset, data: data, params: params}) do
    {:ok, %{}}
    |> assign_original(params)
    |> assign_changeset(changeset)
    |> assign_data(data)
    ~>> run_changeset()
    ~>> validate_changeset()
    # Add nils back
    # Print errors if there are any
#     case params.valid? do
#       true -> 
#         {:ok, data |> Map.put(:params, Params.to_map(params))}
#       _ -> params_error(params)
#     end
  end

  ###
  ### PRIVATE
  ###

  defp run_changeset(%{original_data: data, original_params: params, changeset_function: changeset} = msg) do
    {:ok, msg |> Map.put(:changeset, changeset.(data, params))}
  end

  defp validate_changeset(%{changeset: changeset} = msg) do
    if changeset.valid? do
      {:ok, msg}
    else
      params_error(changeset)
    end
  end

  defp params_error(changeset) do
    {:error, %{errors: translate_errors(changeset)}}
  end

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(ParamUtils.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ParamUtils.Gettext, "errors", msg, opts)
    end
  end

  defp translate_errors(changeset) do
    changeset |> Ecto.Changeset.traverse_errors(&translate_error/1)
  end
end
