defmodule SandboxFirmware.Plug do
  use Plug.Router

  # Allow access for
  # - /assets/sandbox_client.mjs
  plug Plug.Static,
    at: "/",
    from: {:sandbox_firmware, "priv/static"},
    only: ["assets"]

  # Allow access for
  # - /lustre-server-component.mjs
  plug Plug.Static,
    at: "/",
    from: {:lustre, "priv/static"}

  plug :match
  plug :dispatch

  get "favicon.ico" do
    send_resp(conn, 200, "")
  end

  get "/ws/lustre/counter",
    to: SandboxFirmware.ServerComponent,
    init_opts: [app_module: :counter]

  get "/" do
    send_resp(conn, 200, """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Document</title>
            <script type="module" src="/assets/sandbox_client.mjs"></script>
            <script type="module" src="/lustre-server-component.mjs"></script>
        </head>
        <body>
            <counter-component></counter-component>
            #{SandboxFirmware.ServerComponent.component_at("/ws/lustre/counter")}
        </body>
    </html>
    """)
  end
end
