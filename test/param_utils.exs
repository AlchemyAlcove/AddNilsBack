defmodule ParamUtilsTest do
  use ExUnit.Case
  doctest ParamUtils

  test "empty" do
    assert ParamUtils.add_nils_back({:ok, %{params: %{}}}, [], []) == {:ok, %{params: %{}}}
  end
end
