defmodule ValidationTest do
  use ExUnit.Case
  import RethinkDB.Lambda

  setup do
    Application.put_env(:rethinkdb_ecto_test, TestRepo, [])

    {:ok, conn} = RethinkDB.Connection.start_link
    {:ok, _} = TestRepo.start_link
    RethinkDB.Query.table_create("posts") |> RethinkDB.Connection.run(conn)
    {:ok, model} = TestRepo.insert(%TestModel{title: "yay"})

    {:ok, model: model}
  end

  test "required attr must be provided" do
    date = Ecto.DateTime.utc
    test_changeset = TestRepo.changeset(%TestModel{}, %{date: date})
    {:error, changeset} = TestRepo.insert(test_changeset)

    assert changeset.errors == [title: "can't be blank"]
  end

  test "all attr must be in schema" do
    test_changeset = TestRepo.changeset(%TestModel{}, %{title: "yaya", yoy: "yoy"})
    {:error, changeset} = TestRepo.insert(test_changeset)

    assert changeset.errors == [title: "can't be blank"]
  end

  test "schema types are enforced" do
    test_changeset = TestRepo.changeset(%TestModel{}, %{title: 123})
    {:error, changeset} = TestRepo.insert(test_changeset)

    assert changeset.errors == [title: "is invalid"]
  end
end
