defmodule BabysittingWeb.Router do
  use BabysittingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BabysittingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BabysittingWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    live "/children", ChildLive.Index, :index
    live "/children/new", ChildLive.Index, :new
    live "/children/:id/edit", ChildLive.Index, :edit

    live "/children/:id", ChildLive.Show, :show
    live "/children/:id/show/edit", ChildLive.Show, :edit

    live "/transactions", TransactionLive.Index, :index
    live "/transactions/new", TransactionLive.Index, :new
    live "/transactions/:id/edit", TransactionLive.Index, :edit

    live "/transactions/:id", TransactionLive.Show, :show
    live "/transactions/:id/show/edit", TransactionLive.Show, :edit
  end

  scope "/api", BabysittingWeb.API do
    pipe_through :api

    get("/users", APIController, :index_users)
    get("/users/:id", APIController, :show_user)
    post("/users/new", APIController, :create_new_user)
    patch("/users/:id", APIController, :edit_user)
    post("/children/new", APIController, :create_new_child)
    post("/transactions/new", APIController, :create_new_transaction)
    patch("/transactions/:id", APIController, :edit_transaction)
    delete("/transactions/:id", APIController, :delete_transaction)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:babysitting, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BabysittingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
