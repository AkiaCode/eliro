defmodule Conf do
    defp config() do
        case File.read("config/eliro.conf") do
          {:ok, body} ->
            String.split(body, ~r/\||[\r\n]/, trim: true)
            |> Enum.chunk_every(2)
            |> Enum.map(fn [a, b] -> {a, b} end)
            |> Map.new()
    
          {:error, reason} ->
            IO.puts(:stderr, "Error: #{reason}")
        end
    end

    def get_key() do
        Map.keys(config()) |> Enum.at(0)
    end
    
    def get_port() do
        key = get_key()
        String.to_integer(key)
    end
    
    def get_value() do
        key = get_key()
        config()[key]
    end
    
    def get_domian(index) do
        value = get_value()
        domain = String.split(value, ":", trim: true)
        Enum.at(domain, index)
    end
end