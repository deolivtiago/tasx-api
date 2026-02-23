defmodule TasxCore.Access.Emails.VerificationCode.Send do
  @moduledoc false

  alias TasxCore.Access.Emails
  alias TasxCore.Access.Users.User
  alias TasxCore.Mailer

  @doc false
  def call(%User{} = user, code) do
    user
    |> Emails.VerificationCode.new(code)
    |> Mailer.send_email()
  end
end
