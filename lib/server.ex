defmodule Todo.Server do
  use GenServer

  def start(), do: GenServer.start(Todo.List, nil)

  def add_entry(pid, entry), do: GenServer.cast(pid, {:add_entry, entry})

  def entries(pid, date), do: GenServer.call(pid, {:entries, date})

  def update_entry(pid, %{} = new_entry), do: update_entry(pid, new_entry.id, fn(_) -> new_entry end)
  def update_entry(pid, entry_id, updater_fn), do: GenServer.cast(pid, {:update_entry, entry_id, updater_fn}) 

  def delete_entry(pid, entry_id), do: GenServer.cast(pid, {:delete_entry, entry_id})

  def init(_), do: {:ok, Todo.List.new()}

  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  def handle_cast({:update_entry, entry_id, updater_fn}, todo_list) do
    new_state = Todo.List.update_entry(todo_list, entry_id, updater_fn)
    {:noreply, new_state}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    new_state = Todo.List.delete_entry(todo_list, entry_id)
    {:noreply, new_state}
  end

  def handle_call({:entries, date}, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end
