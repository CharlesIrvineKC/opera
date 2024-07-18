defmodule OperaWeb.TasksLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        user_tasks: ProcessService.get_user_tasks(),
        current_task: nil
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-10 border border-black flex flex-row">
      <div>
        <.user_task_ref
          :for={user_task <- @user_tasks}
          task_name={user_task.name}
          task_id={user_task.uid}
          process_key={user_task.process_key}
        >
        </.user_task_ref>
      </div>
      <div>
        <.task_form current_task={@current_task} />
      </div>
    </div>
    """
  end

  def user_task_ref(assigns) do
    ~H"""
    <a
      phx-click="select_task" phx-value-task-id={@task_id}
      href="#"
      class="block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
    >
      <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
      <%= @task_name %>
      </h5>
      <p class="font-normal text-gray-700 dark:text-gray-400">
      Customer: <%= @process_key %>
      </p>
    </a>
    """
  end

  def task_form(assigns) do
    ~H"""
      <form :if={@current_task} class="max-w-sm m-10">
        <div class="mb-5">
          <label for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Your email
          </label>
          <input
            type="email"
            id="email"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            placeholder="name@flowbite.com"
            required
          />
        </div>
        <div class="mb-5">
          <label for="password" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            Your password
          </label>
          <input
            type="password"
            id="password"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            required
          />
        </div>
        <div class="flex items-start mb-5">
          <div class="flex items-center h-5">
            <input
              id="remember"
              type="checkbox"
              value=""
              class="w-4 h-4 border border-gray-300 rounded bg-gray-50 focus:ring-3 focus:ring-blue-300 dark:bg-gray-700 dark:border-gray-600 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:focus:ring-offset-gray-800"
              required
            />
          </div>
          <label for="remember" class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">
            Remember me
          </label>
        </div>
        <button
          type="submit"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Submit
        </button>
      </form>
    """
  end

  def handle_event("select_task", %{"task-id" => task_id}, socket) do
    task = Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_id end)
    {:noreply, assign(socket, current_task: task)}
  end
end
