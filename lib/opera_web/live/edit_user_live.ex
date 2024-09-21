defmodule OperaWeb.EditUserLive do
  use OperaWeb, :live_view

  alias Opera.Admin

  def mount(%{"user_id" => user_id}, _session, socket) do
    users_groups = (Admin.get_user_groups(user_id) || []) |> Enum.sort()
    other_groups = (Admin.get_all_groups() -- users_groups) |> Enum.sort()

    {:ok,
     assign(socket, users_groups: users_groups, other_groups: other_groups, user_id: user_id)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-8">
      <.add_groups other_groups={@other_groups} />
      <h3 class="mt-6 text-3xl font-bold dark:text-white">Groups for <%= @user_id %></h3>
      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
          <tbody>
            <tr
              :for={group <- @users_groups}
              class="odd:bg-white odd:dark:bg-gray-900 even:bg-gray-50 even:dark:bg-gray-800 border-b dark:border-gray-700"
            >
              <th
                scope="row"
                class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white"
              >
                <%= group %>
              </th>
              <td class="px-6 py-4">
                <a
                  phx-click="remove-class"
                  phx-value-removed-group={group}
                  href="#"
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Remove
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def add_groups(assigns) do
    ~H"""
    <div class="">
      <button
        id="groupFilterButton"
        phx-click={JS.toggle_class("hidden", to: "#groupFilterCheckbox")}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-light text-xs px-3 py-1.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        type="button"
      >
        Add Groups
        <svg
          class="w-2.5 h-2.5 ms-3"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 10 6"
        >
          <path
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="m1 1 4 4 4-4"
          />
        </svg>
      </button>
      <!-- Dropdown menu -->
      <div class="relative">
        <div class="absolute top-0 z-10">
          <div
            id="groupFilterCheckbox"
            class="hidden top-0 w-48 bg-white divide-y divide-gray-100 rounded-lg shadow dark:bg-gray-700 dark:divide-gray-600"
          >
            <ul
              class="p-3 space-y-3 text-sm text-gray-700 dark:text-gray-200"
              aria-labelledby="groupFilterButton"
            >
              <li :for={group <- @other_groups}>
                <div class="flex items-center">
                  <input
                    id={"checkbox-#{group}"}
                    phx-click="select-group"
                    phx-value-changed-group={group}
                    type="checkbox"
                    value={group}
                    name={"checkbox-#{group}"}
                    class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-700 dark:focus:ring-offset-gray-700 focus:ring-2 dark:bg-gray-600 dark:border-gray-500"
                  />
                  <label
                    for={"checkbox-#{group}"}
                    class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
                  >
                    <%= group %>
                  </label>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("select-group", %{"changed-group" => group, "value" => group}, socket) do
    user_id = socket.assigns.user_id
    Admin.add_user_to_group(user_id, group)
    users_groups = (Admin.get_user_groups(user_id) || []) |> Enum.sort()
    other_groups = (Admin.get_all_groups() -- users_groups) |> Enum.sort()
    {:noreply, assign(socket, users_groups: users_groups, other_groups: other_groups)}
  end

  def handle_event("remove-class", %{"removed-group" => group}, socket) do
    user_id = socket.assigns.user_id
    Admin.remove_user_from_group(user_id, group)
    users_groups = (Admin.get_user_groups(user_id) || []) |> Enum.sort()
    other_groups = (Admin.get_all_groups() -- users_groups) |> Enum.sort()
    {:noreply, assign(socket, users_groups: users_groups, other_groups: other_groups)}
  end
end
