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
    <div class="mx-10 flex flex-row">
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
      class="block max-w-sm my-2 p-4 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
    >
      <h5 class="mb-2 text-lg font-bold tracking-tight text-gray-900 dark:text-white">
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
      <form :if={@current_task} phx-submit="complete_task" class="ml-8">
        <div class="grid grid-cols-3 gap-6">
          <.input_field :for={{name, value} <- @current_task.data} name={name} value={value}/>
        </div>
        <div class="grid grid-cols-3 gap-6 mb-8">
          <.output_field :for={name <- @current_task.outputs} name={name} value=""/>
        </div>
        <div class="flex flex-col items-center">
        <button
          type="submit"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm text-center px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Submit
        </button>
        </div>
      </form>
    """
  end

  def input_field(assigns) do
    ~H"""
      <div class="mb-5">
          <label for="input" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            <%= @name %>
          </label>
          <input
            type="text"
            id="input"
            class="bg-gray-100 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            value={@value}
            disabled
          />
        </div>
    """
  end

  def output_field(assigns) do
    ~H"""
      <div class="mb-5">
          <label for="output" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
            <%= @name %>
          </label>
          <input
            type="text"
            id="output"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            value={@value}
          />
        </div>
    """
  end

  def handle_event("select_task", %{"task-id" => task_id}, socket) do
    task = Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_id end)
    {:noreply, assign(socket, current_task: task)}
  end

  def handle_event("complete_task", _, socket) do

  end
end
