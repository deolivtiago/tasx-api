defmodule TasxCore.Access.Emails.VerificationCode do
  @moduledoc false

  alias Swoosh.Email
  alias TasxCore.Access.Users.User

  @doc ~S"""
  Creates a new `Swoosh.Email` to verify an user

  ## Example

      iex> new(user, code)
      %Swoosh.Email{}

  """
  def new(%User{} = user, code) when is_binary(code) do
    first_name = String.split(user.full_name, " ") |> List.first()
    email_content = text_instructions(first_name, code)

    Email.new()
    |> Email.from({"Tasx", "tasx@demomailtrap.com"})
    |> Email.to({first_name, user.email})
    |> Email.subject("Verification Code")
    |> Email.text_body(email_content)
  end

  defp text_instructions(first_name, code) do
    """

    ==============================

    Hi #{first_name},

    Please, access your app and enter the code below to confirm the verification:

    #{code}

    If you didn't request any change, please ignore this.

    ==============================
    """
  end
end
