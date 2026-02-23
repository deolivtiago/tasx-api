defmodule TasxCore.Board.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TasxCore.Board.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        position: 42,
        priority: :high,
        progress: 42,
        status: :draft,
        title: "some title"
      })
      |> TasxCore.Board.Tasks.create_task()

    task
  end
end
