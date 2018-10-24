defmodule AssignOriginalTest do
  use ExUnit.Case

  test "error" do
    assert ParamUtils.assign_original({:error, %{params: %{}}}, %{"name" => "Bob"}) == {:error, %{params: %{}}}
  end

  test "ok" do
    assert ParamUtils.assign_original({:ok, %{params: %{}}}, %{"name" => "Bob"}) == {:ok, %{original_params: %{"name" => "Bob"}, params: %{}}}
  end
end
