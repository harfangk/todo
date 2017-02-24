defmodule Todo.Server do
  use GenServer

  def start(name), do: GenServer.start(Todo.Server, name)

  def add_entry(pid, entry), do: GenServer.cast(pid, {:add_entry, entry})

  def entries(pid, date), do: GenServer.call(pid, {:entries, date})

  def update_entry(pid, %{} = new_entry), do: update_entry(pid, new_entry.id, fn(_) -> new_entry end)
  def update_entry(pid, entry_id, updater_fn), do: GenServer.cast(pid, {:update_entry, entry_id, updater_fn}) 

  def delete_entry(pid, entry_id), do: GenServer.cast(pid, {:delete_entry, entry_id})

  def init(name), do: {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, new_state}
  end

  def handle_cast({:update_entry, entry_id, updater_fn}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, entry_id, updater_fn)
    Todo.Database.store(name, new_state)
    {:noreply, new_state}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_state)
    {:noreply, new_state}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end
