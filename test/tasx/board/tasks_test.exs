defmodule TasxCore.Board.TasksTest do
  use TasxCore.DataCase

  alias TasxCore.Board.Tasks

  describe "tasks" do
    alias TasxCore.Board.Tasks.Task

    import TasxCore.Board.TasksFixtures

    @invalid_attrs %{position: nil, priority: nil, status: nil, progress: nil, description: nil, title: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{position: 42, priority: :high, status: :draft, progress: 42, description: "some description", title: "some title"}

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.position == 42
      assert task.priority == :high
      assert task.status == :draft
      assert task.progress == 42
      assert task.description == "some description"
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{position: 43, priority: :medium, status: :open, progress: 43, description: "some updated description", title: "some updated title"}

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.position == 43
      assert task.priority == :medium
      assert task.status == :open
      assert task.progress == 43
      assert task.description == "some updated description"
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
