defmodule Todo.Cache do
  use GenServer

  def init(_) do
    {:ok, Map.new()}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    todo_server_pid = case Todo.Server.whereis(todo_list_name) do
      :undefined -> 
        {:ok, pid} = Todo.ServerSupervisor.start_child(todo_list_name)
        pid

      pid -> pid
    end
    {:reply, todo_server_pid, todo_servers}
  end

  def start_link() do
    IO.puts "Starting todo cache"
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      :undefined -> GenServer.call(:todo_cache, {:server_process, todo_list_name})
      pid -> pid
    end
  end
end
