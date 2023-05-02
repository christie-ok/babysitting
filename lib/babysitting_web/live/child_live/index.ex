defmodule BabysittingWeb.ChildLive.Index do
  use BabysittingWeb, :live_view

  alias Babysitting.Children
  alias Babysitting.Children.Child

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :children, Children.list_children())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Child")
    |> assign(:child, Children.get_child!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Child")
    |> assign(:child, %Child{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Children")
    |> assign(:child, nil)
  end

  @impl true
  def handle_info({BabysittingWeb.ChildLive.FormComponent, {:saved, child}}, socket) do
    {:noreply, stream_insert(socket, :children, child)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    child = Children.get_child!(id)
    {:ok, _} = Children.delete_child(child)

    {:noreply, stream_delete(socket, :children, child)}
  end
end
