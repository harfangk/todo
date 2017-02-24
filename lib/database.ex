defmodule Todo.Database do
  use GenServer

  def start_link(db_folder), do: GenServer.start_link(__MODULE__, db_folder, name: :database_server) 

  def store(key, data) do
    key
    |> get_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> get_worker()
    |> Todo.DatabaseWorker.get(key)
  end
  
  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  defp start_workers(db_folder) do
    for index <- 0..2, into: Map.new() do
      {:ok, worker_pid} = Todo.DatabaseWorker.start_link(db_folder)
      {index, worker_pid}
    end
  end

  def get_worker(key) do
    GenServer.call(:database_server, {:get_worker, key})
  end

  def handle_call({:get_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end
end
