defmodule TasxWeb.AuthControllerTest do
  use TasxWeb.ConnCase, async: true

  import TasxCore.Access.TokenFixtures
  import TasxCore.Access.RoleFixtures
  import TasxCore.Access.UserFixtures

  alias TasxCore.Access.Users.User

  setup %{conn: conn} do
    conn
    |> put_req_header("accept", "application/json")
    |> then(&{:ok, conn: &1})
  end

  describe "sign_up/2 returns" do
    test "success when the user params are valid", %{conn: conn} do
      user_params = user_attrs(%{verified?: false})

      conn = post(conn, ~p"/api/auth/sign-up", user_params)

      assert %{"data" => user_data} = json_response(conn, :created)

      assert user_data["id"]
      assert user_data["full_name"] == user_params.full_name
      assert user_data["email"] == user_params.email
      assert user_data["avatar_url"] == user_params.avatar_url
      assert user_data["role_id"] == user_params.role_id
      assert user_data["is_verified"] == user_params.verified?
    end

    test "error when the user params are invalid", %{conn: conn} do
      user_params = %{email: "", full_name: nil, password: "?"}

      conn = post(conn, ~p"/api/auth/sign-up", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["full_name"], "can't be blank")
      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "should be at least 6 character(s)")
    end

    test "error when the user email has already been taken", %{conn: conn} do
      user_params = user_attrs(%{email: insert_user().email})

      conn = post(conn, ~p"/api/auth/sign-up", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has already been taken")
    end
  end

  describe "sign_in/2 returns" do
    setup [:put_user]

    test "success when user credentials are correct", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?"}

      conn = post(conn, ~p"/api/auth/sign-in", user_params)

      assert %{"data" => auth_data} = json_response(conn, :ok)

      assert auth_data["access_token"]
      assert auth_data["refresh_token"]
    end

    test "error when user credentials are incorrect", %{conn: conn} do
      user_params = %{email: "wrong@mail.com", password: "???"}

      conn = post(conn, ~p"/api/auth/sign-in", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "invalid credentials")
      assert Enum.member?(errors["password"], "invalid credentials")
    end

    test "error when user credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/sign-in", %{})

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "can't be blank")
    end
  end

  describe "send_code/2 returns" do
    setup [:put_user]

    test "success when the email has been sent to user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/auth/send-code", email: user.email)

      assert response(conn, :no_content)
    end

    test "error when the email is not found", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/send-code", email: "not.found@mail.com")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "not found")
    end

    test "error when the email is not given", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/send-code")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
    end

    test "error when the email is invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/send-code", email: "???")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has invalid format")
    end
  end

  describe "confirm_account/2 returns" do
    test "success when verification code is valid", %{conn: conn} do
      user = insert_user(%{verified?: false})
      user_params = %{email: user.email, code: User.new_verification_code(user)}

      conn = post(conn, ~p"/api/auth/confirm-account", user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"]
      assert user_data["full_name"] == user.full_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role_id"] == user.role_id
      assert user_data["is_verified"] == true
    end

    test "error when verification code is invalid", %{conn: conn} do
      user = insert_user(%{verified?: false})
      user_params = %{email: user.email, code: "123456"}

      conn = post(conn, ~p"/api/auth/confirm-account", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["code"], "is invalid")
    end

    test "error when verification code is not given", %{conn: conn} do
      user_params = %{email: insert_user().email}

      conn = post(conn, ~p"/api/auth/confirm-account", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["code"], "can't be blank")
    end

    test "error when email is not given", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/confirm-account", %{code: "123456"})

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
    end

    test "error when email is not found", %{conn: conn} do
      user_params = %{email: "not.found@mail.com", code: "123456"}

      conn = post(conn, ~p"/api/auth/confirm-account", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "not found")
    end

    test "error when email is invalid", %{conn: conn} do
      user_params = %{email: "???", code: "???"}

      conn = post(conn, ~p"/api/auth/confirm-account", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has invalid format")
      assert Enum.member?(errors["code"], "should be 6 character(s)")
    end
  end

  describe "reset_password/2 returns" do
    test "success when verification code is valid", %{conn: conn} do
      user = insert_user(%{verified?: false})

      user_params = %{
        email: user.email,
        code: User.new_verification_code(user),
        new_password: "NewP455w0rd!"
      }

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"]
      assert user_data["full_name"] == user.full_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role_id"] == user.role_id
      assert user_data["is_verified"] == true

      new_credentials = %{email: user_params.email, password: user_params.new_password}
      assert post(conn, ~p"/api/auth/sign-in", new_credentials) |> response(:ok)
    end

    test "error when verification code is invalid", %{conn: conn} do
      user_params = %{email: insert_user().email, code: "666666", new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["code"], "is invalid")
    end

    test "error when verification code is not given", %{conn: conn} do
      user_params = %{email: insert_user().email, new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["code"], "can't be blank")
    end

    test "error when email is not given", %{conn: conn} do
      user_params = %{code: "666666", new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
    end

    test "error when email is not found", %{conn: conn} do
      user_params = %{email: "not.found@mail.com", code: "666666", new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "not found")
    end

    test "error when email is invalid", %{conn: conn} do
      user_params = %{email: "???", code: "666666", new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has invalid format")
    end

    test "error when the new password is not given", %{conn: conn} do
      user = insert_user()

      user_params = %{email: user.email, code: User.new_verification_code(user)}

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["new_password"], "can't be blank")
    end

    test "error when the new password is invalid", %{conn: conn} do
      user = insert_user()

      user_params = %{
        email: user.email,
        code: User.new_verification_code(user),
        new_password: "???"
      }

      conn = post(conn, ~p"/api/auth/reset-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["password"], "must have number(s)")
    end
  end

  describe "change_email/2 returns" do
    setup [:put_user]

    test "success when user credentials are correct", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?", new_email: "new_email@mail.com"}

      conn = post(conn, ~p"/api/auth/change-email", user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"]
      assert user_data["full_name"] == user.full_name
      assert user_data["email"] == user_params.new_email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role_id"] == user.role_id
      assert user_data["is_verified"] == false

      new_credentials = %{email: user_params.new_email, password: user_params.password}
      conn = post(conn, ~p"/api/auth/sign-in", new_credentials)
      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)
      assert Enum.member?(errors["email"], "must be verified")
    end

    test "error when user credentials are incorrect", %{conn: conn} do
      user_params = %{email: "wrong@mail.com", password: "???", new_email: "new_email@mail.com"}

      conn = post(conn, ~p"/api/auth/change-email", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "invalid credentials")
      assert Enum.member?(errors["password"], "invalid credentials")
    end

    test "error when user credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/change-email", %{new_email: "new_email@mail.com"})

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "can't be blank")
    end

    test "error when the new email is not given", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?"}

      conn = post(conn, ~p"/api/auth/change-email", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["new_email"], "can't be blank")
    end

    test "error when the new email is invalid", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?", new_email: "???"}

      conn = post(conn, ~p"/api/auth/change-email", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["new_email"], "has invalid format")
    end
  end

  describe "change_password/2 returns" do
    setup [:put_user]

    test "success when user credentials are correct", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?", new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/change-password", user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"]
      assert user_data["full_name"] == user.full_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role_id"] == user.role_id
      assert user_data["is_verified"] == user.verified?

      new_credentials = %{email: user_params.email, password: user_params.new_password}
      assert post(conn, ~p"/api/auth/sign-in", new_credentials) |> response(:ok)
    end

    test "error when user credentials are incorrect", %{conn: conn} do
      user_params = %{email: "wrong@mail.com", password: "???", new_password: "NewP455w0rd!"}

      conn = post(conn, ~p"/api/auth/change-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "invalid credentials")
      assert Enum.member?(errors["password"], "invalid credentials")
    end

    test "error when user credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/change-password", %{new_password: "NewP455w0rd!"})

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "can't be blank")
    end

    test "error when the new password is not given", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?"}

      conn = post(conn, ~p"/api/auth/change-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["new_password"], "can't be blank")
    end

    test "error when the new password is invalid", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?", new_password: "???"}

      conn = post(conn, ~p"/api/auth/change-password", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["new_password"], "must have uppercase character(s)")
    end
  end

  describe "refresh_token/2 returns" do
    setup [:put_user]

    test "success when token is valid", %{conn: conn, user: user} do
      token = insert_token(user, typ: :refresh) |> Map.get(:token)

      conn = post(conn, ~p"/api/auth/refresh-token", token: token)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["access_token"]
      assert user_data["refresh_token"]
    end

    test "error when token is invalid", %{conn: conn, user: user} do
      token = insert_token(user, typ: :refresh) |> Map.get(:token)

      post(conn, ~p"/api/auth/refresh-token", token: token)
      conn = post(conn, ~p"/api/auth/refresh-token", token: token)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["token"], "is invalid")
    end

    test "error when token is not given", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/refresh-token")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["token"], "can't be blank")
    end
  end

  describe "sign_out/2 returns" do
    setup [:put_user]

    test "success when deleting tokens", %{conn: conn, user: user} do
      tokens =
        Map.new()
        |> Map.put(:access_token, insert_token(user, typ: :access) |> Map.get(:token))
        |> Map.put(:refresh_token, insert_token(user, typ: :refresh) |> Map.get(:token))

      assert response(delete(conn, ~p"/api/auth/sign-out"), :no_content)
      assert response(delete(conn, ~p"/api/auth/sign-out", tokens), :no_content)
      assert response(delete(conn, ~p"/api/auth/sign-out", %{access_token: true}), :no_content)
    end
  end

  describe "user_info/2 returns" do
    setup [:put_user]

    test "success when the user is authenticated", %{conn: conn, user: user} do
      token = insert_token(user, typ: :access) |> Map.get(:token)

      conn =
        put_req_header(conn, "authorization", "Bearer #{token}") |> get(~p"/api/auth/user-info")

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["full_name"] == user.full_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role_id"] == user.role_id
      assert user_data["is_verified"] == user.verified?
    end

    test "error when the user is not authenticated", %{conn: conn} do
      assert response(get(conn, ~p"/api/auth/user-info"), :unauthorized)
    end
  end

  defp put_user(_) do
    role_id = insert_role(%{permissions: ["GET:api/auth/user-info"]}).id

    {:ok, user: insert_user(%{role_id: role_id})}
  end
end
