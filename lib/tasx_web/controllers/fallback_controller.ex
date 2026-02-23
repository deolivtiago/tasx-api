defmodule TasxWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TasxWeb, :controller

  @doc """
  This clause handles errors returned by `Ecto.Changeset`
  """
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: TasxWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end
end
