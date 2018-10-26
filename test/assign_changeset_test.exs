defmodule AssignChangesetTest do
  use ExUnit.Case

  def test_function(), do: nil

  test "error" do
    assert ParamUtils.assign_changeset({:error, %{original_params: %{}, params: %{}}}, &test_function/0) == {:error, %{original_params: %{}, params: %{}}}
  end

  test "ok" do
    func_ref = &test_function/0
    assert ParamUtils.assign_changeset({:ok, %{original_params: %{}, params: %{}}}, func_ref) == {:ok, %{original_params: %{}, changeset_function: func_ref, params: %{}}}
  end
end
