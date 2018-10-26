defmodule ConvertParamsTest do
  use ExUnit.Case

  test "convert params" do
    params = %{
      "email" => "test",
      "password" => "password"
    }
    changeset = &ParamUtils.LoginSchema.changeset/2

    {:ok, resp} = ParamUtils.convert_params(%{changeset: changeset, data: %ParamUtils.LoginSchema{}, params: params})
    assert resp.original_params == %{"email" => "test", "password" => "password"}
    assert resp.changeset_function == changeset
    assert resp.changeset.errors == [email: {"has invalid format", [validation: :format]}]
  end
end
