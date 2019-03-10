defmodule TodoListImportTest do
  use ExUnit.Case


  def entries() do
    [
      %{date: ~D[2018-12-19], title: "Dentist"},
      %{date: ~D[2018-12-20], title: "Shopping"},
      %{date: ~D[2018-12-19], title: "Movies"}
    ]
  end

  test "build a todo list manually" do
    todos = TodoList.new(entries())
    assert length(TodoList.entries(todos, ~D[2018-12-19])) == 2
  end

  test "import a todo lost from a CSV file" do
    todos = TodoList.CsvImporter.import("todos.csv")
    assert todos == TodoList.new(entries())
  end
end
