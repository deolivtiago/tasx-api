defmodule TasxWeb.ErrorJSONTest do
  use TasxWeb.ConnCase, async: true

  alias TasxWeb.ErrorJSON

  test "renders 500" do
    assert %{errors: errors} = ErrorJSON.render("500.json", %{})

    assert errors == %{detail: "Internal Server Error"}
  end
end
