defmodule OperaWeb.TestLive do
  use OperaWeb, :live_view

  def mount(_params, _session, socket) do
    names = ["one", "two", "three"]
    selected_name = nil
    show_modal = false
    {:ok, assign(socket, names: names, selected_name: selected_name, show_modal: show_modal)}
  end

  def render(assigns) do
    ~H"""
    <button
      :for={name <- @names}
      phx-click="record-name"
      phx-value-name={name}
      type="button"
      class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
    >
      <%= name %>
    </button>
    <.my_modal selected_name={@selected_name} show_modal={@show_modal} />
    """
  end

  def my_modal(assigns) do
    IO.inspect(assigns, label: "** assigns **")

    ~H"""
    <.modal show={true} id="confirm">
      <%= @selected_name %>
    </.modal>
    """
  end

  def handle_event("record-name", %{"name" => name}, socket) do
    IO.inspect(name, label: "*** name in handle event **")
    {:noreply, assign(socket, selected_name: name, show_modal: true)}
  end
end
