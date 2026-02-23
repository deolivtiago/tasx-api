defmodule TasxWeb.AuthenticationPlug do
  @moduledoc false

  import Plug.Conn

  alias TasxCore.Access.Tokens

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    case verify_token(conn) do
      {:ok, %{user: user}} ->
        assign(conn, :current_user, user)

      _error ->
        send_resp(conn, :unauthorized, "") |> halt()
    end
  end

  defp verify_token(conn) do
    conn
    |> get_req_header("authorization")
    |> Enum.reduce("", &to_token/2)
    |> Tokens.verify_token(:access)
  end

  defp to_token(new_token, last_token) do
    if String.starts_with?(new_token, "Bearer "),
      do: String.trim_leading(new_token, "Bearer "),
      else: last_token
  end
end
