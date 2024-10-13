defmodule OperaWeb.AdminLive do
  alias Opera.Accounts
  use OperaWeb, :live_view

  on_mount {OperaWeb.UserAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-6">
      <.users users={@users} />
    </div>
    """
  end

  def users(assigns) do
    ~H"""
    <h3 class="mt-6 text-3xl font-bold dark:text-white">Users</h3>
    <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
        <tbody>
          <tr
            :for={user <- @users}
            class="odd:bg-white odd:dark:bg-gray-900 even:bg-gray-50 even:dark:bg-gray-800 border-b dark:border-gray-700"
          >
            <th
              scope="row"
              class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white"
            >
              <%= user.email %>
            </th>
            <td class="px-6 py-4">
              <a href={~p"/admin/#{user.email}"} class="font-medium text-blue-600 dark:text-blue-500 hover:underline">
                Edit
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def groups(assigns) do
    ~H"""
    """
  end
end
