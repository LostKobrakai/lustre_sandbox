defmodule SandboxFirmware.ServerComponent do
  @moduledoc """
  Plug to upgrade request to websocket connection and starting `WebSock` handler.
  """

  defmodule Handler do
    # Using separate module because `init/1` callback exists in
    # both Plug and WebSock behaviour.
    @behaviour WebSock

    @impl WebSock
    def init(%{app_module: app_module}) do
      self = self()

      # Start app handling actor
      {:ok, actor} = :lustre.start_actor(app_module.app(), nil)

      # Subscribe to actor updates
      subscription =
        :lustre@server_component.subscribe("ws", fn patch ->
          send(self, {:patch, patch})
          nil
        end)

      :gleam@erlang@process.send(actor, subscription)

      {:ok, %{actor: actor}}
    end

    @impl WebSock
    def handle_in({msg, [opcode: :text]}, state) do
      case :gleam@json.decode(msg, &:lustre@server_component.decode_action/1) do
        {:ok, action} -> :gleam@erlang@process.send(state.actor, action)
        _ -> :ok
      end

      {:ok, state}
    end

    @impl WebSock
    def handle_info({:patch, patch}, state) do
      patch_text =
        patch
        |> :lustre@server_component.encode_patch()
        |> :gleam@json.to_string()

      {:push, {:text, patch_text}, state}
    end
  end

  @behaviour Plug

  @impl Plug
  def init(opts) do
    app_module = Keyword.fetch!(opts, :app_module)
    %{app_module: app_module}
  end

  @impl Plug
  def call(%Plug.Conn{} = conn, %{app_module: app_module}) do
    conn
    |> WebSockAdapter.upgrade(Handler, %{app_module: app_module}, [])
    |> Plug.Conn.halt()
  end

  def component_at(path) do
    route = :lustre@server_component.route(path)
    component = :lustre@server_component.component([route])
    :lustre@element.to_string_builder(component)
  end
end
