defmodule TasxWeb.AuthorizationPlug do
  @moduledoc false

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(%{assigns: %{current_user: %{role_id: "root"}}} = conn, _opts), do: conn

  def call(%{assigns: %{current_user: %{role: role}}} = conn, _opts) do
    permission = get_permission_from_path(conn)

    if not Enum.member?(role.permissions, permission),
      do: send_resp(conn, :forbidden, "") |> halt(),
      else: conn
  end

  defp get_permission_from_path(conn) do
    path =
      conn.path_info
      |> Enum.reject(&Enum.member?(Map.values(conn.path_params), &1))
      |> Enum.join("/")

    Enum.join([conn.method, path], ":")
  end
end
