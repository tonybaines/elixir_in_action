# From EiA ch4/todo_builder.ex
defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{
      todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule TodoList.CsvImporter do
  def import(file_name) do

    entries = File.stream!(file_name)
              |> Stream.map(&String.trim_trailing/1)
              |> Stream.map(&String.split(&1, ","))
              |> Stream.map(&List.to_tuple/1)
              |> Stream.map(&to_entry/1)
    #              |> Enum.to_list
    #              |> IO.inspect

    TodoList.new(entries)
  end

  def to_entry({date_str, title}) do
    {:ok, date} = String.split(date_str, "/")
                  |> List.to_tuple
                  |> to_date
    %{date: date, title: title}
  end

  def to_date({yr, mon, day}) do
    Date.new(
      String.to_integer(yr),
      String.to_integer(mon),
      String.to_integer(day)
    )
  end
end