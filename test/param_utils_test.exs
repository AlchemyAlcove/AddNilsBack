defmodule ParamUtilsTest do
  use ExUnit.Case
  doctest ParamUtils

  test "empty" do
    assert ParamUtils.add_nils_back({:ok, %{params: %{}}}, [], []) == {:ok, %{params: %{}}}
  end

  test "Two params with one nil" do
    original = %{
      "colors" => "Orange",
      "image" => nil
    }
    assert ParamUtils.add_nils_back({:ok, %{params: %{colors: "Orange"}}}, original, ["colors", "image"]) == {:ok, %{params: %{colors: "Orange", image: nil}}}
  end

  test "Two params with no nil" do
    original = %{
      "colors" => "Orange",
      "image" => "https://google.com/lkajsd"
    }
    assert ParamUtils.add_nils_back({:ok, %{params: %{colors: "Orange", image: "https://google.com/lkajsd"}}}, original, ["colors", "image"]) == {:ok, %{params: %{colors: "Orange", image: "https://google.com/lkajsd"}}}
  end
end
