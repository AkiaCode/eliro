require Logger

defmodule Eliro do
  def run do
    children = [
     {Task.Supervisor, [name: Eliro.TaskSupervisor]},
     Supervisor.child_spec({Task, fn -> Eliro.accept(Conf.get_port()) end}, restart: :permanent)
    ]
    opts = [strategy: :one_for_one, children: Eliro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end
  
  defp loop_acceptor(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        {:ok, pid} = Task.Supervisor.start_child(Eliro.TaskSupervisor, fn ->
          case :gen_tcp.connect(String.to_charlist(Conf.get_domian(0)), String.to_integer(Conf.get_domian(1)), [:binary, active: false]) do
            {:ok, socket} ->
              send_client(client, socket)
              serve(client, socket)
            {:error, reason} ->
              Logger.info "ConnectError: #{reason}"
          end
        end)
        :ok = :gen_tcp.controlling_process(client, pid)
        loop_acceptor(socket)
      {:error, reason} ->
        Logger.error "Error accepting connection: #{reason}"
    end
  end

  defp send_server(client, server) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        :gen_tcp.send(server, data)
        Logger.info "Received: #{data}"
      {:error, reason} ->
        Logger.error "ServerError: #{reason}"
    end
  end

  defp send_client(client, server) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        :gen_tcp.send(server, data)
        Logger.info "Received: #{data}"
      {:error, reason} ->
        Logger.error "ClientError: #{reason}"
        :gen_tcp.close(client)
    end
  end

  defp serve(server, client) do
    client
    |> send_server(server)
  end
end

Eliro.run()
