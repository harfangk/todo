defmodule Todo.CsvImporter do
  def import(file) do
    file
    |> File.stream!()
    |> format_entry()
    |> Todo.List.new()
  end

  defp format_entry(s) do
    s
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn([date_string, title_string]) -> [String.split(date_string, "/"), title_string] end)
    |> Stream.map(fn([[y, m, d], title_string]) -> [{String.to_integer(y), String.to_integer(m), String.to_integer(d)}, title_string] end)
    |> Enum.map(fn([date, title]) -> %{date: date, title: title} end)
  end
end
