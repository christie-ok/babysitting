defmodule BabysittingWeb.ChildLive.FormComponent do
  use BabysittingWeb, :live_component

  alias Babysitting.Accounts
  alias Babysitting.Children

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage child records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="child-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <.input field={@form[:birthday]} type="date" label="Birthday" />
        <.input
          field={@form[:gender]}
          type="select"
          label="Gender"
          prompt="Choose a value"
          options={Ecto.Enum.values(Babysitting.Children.Child, :gender)}
        />
        <.input
          field={@form[:parent_id]}
          type="select"
          label="Parent"
          prompt="Choose a parent"
          options={@user_options}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Child</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{child: child} = assigns, socket) do
    changeset = Children.change_child(child)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user_options, Accounts.user_options())
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"child" => child_params}, socket) do
    changeset =
      socket.assigns.child
      |> Children.change_child(child_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"child" => child_params}, socket) do
    save_child(socket, socket.assigns.action, child_params)
  end

  defp save_child(socket, :edit, child_params) do
    case Children.update_child(socket.assigns.child, child_params) do
      {:ok, child} ->
        notify_parent({:saved, child})

        {:noreply,
         socket
         |> put_flash(:info, "Child updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_child(socket, :new, child_params) do
    case Children.create_child(child_params) do
      {:ok, child} ->
        notify_parent({:saved, child})

        {:noreply,
         socket
         |> put_flash(:info, "Child created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
