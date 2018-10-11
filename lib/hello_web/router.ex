# Plug for demo purposes only
# defmodule BackgroundJob.Plug do
#   def init(opts), do: opts
#   def call(conn, opts) do
#     conn
#     |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Background Job"))
#     |> BackgroundJob.Router.call(opts)
#   end
# end

# defmodule BackgroundJob.Router do
#   use Plug.Router

#   plug :match
#   plug :dispatch

#   get "/", do: send_resp(conn, 200, "Welcome to #{conn.assigns.name}")
#   get "/active", do: send_resp(conn, 200, "5 Active Jobs")
#   get "/pending", do: send_resp(conn, 200, "3 Pending Jobs")
#   match _, do: send_resp(conn, 404, "Not found")
# end

defmodule HelloWeb.Router do
  use HelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :review_checks do
    plug :ensure_authenticated_user
    plug :ensure_user_owns_review
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HelloWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController do
      resources "/posts", PostController
    end
    # resources "/posts", PostController, only: [:index, :show]
    resources "/comments", PostController, except: [:delete]
    # resources "/reviews", ReviewController
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show
  end

  scope "/reviews", HelloWeb do
    pipe_through :review_checks

    resources "/", ReviewController
  end

  scope "/admin", HelloWeb.Admin, as: :admin do
    pipe_through :browser

    resources "/images",  ImageController
    resources "/reviews", ReviewController
    resources "/users",   UserController
  end

  scope "/api", HelloWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      resources "/images",  ImageController
      resources "/reviews", ReviewController
      resources "/users",   UserController
    end
  end

  # Used to illustrate pipethrough
  # scope "/" do
  #   pipe_through [:authenticate_user, :ensure_admin]
  #   forward "/jobs", BackgroundJob.Plug, name: "Hello Phoenix!"
  # end

  # Other scopes may use custom stacks.
  # scope "/api", HelloWeb do
  #   pipe_through :api
  # end
end
