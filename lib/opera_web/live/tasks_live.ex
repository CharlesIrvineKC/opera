defmodule OperaWeb.TasksLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService
  alias Mozart.ProcessEngine

  def mount(_params, _session, socket) do
    user_tasks = ProcessService.get_user_tasks()
    bpm_applications = Enum.map(ProcessService.get_bpm_applications(), fn {_k, v} -> v end)

    socket =
      assign(socket,
        user_tasks: user_tasks,
        bpm_applications: bpm_applications,
        current_task: nil,
        current_app: nil
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.nav bpm_applications={@bpm_applications} />
    <div class="mx-10 flex flex-row">
      <div>
        <.user_task_ref
          :for={user_task <- @user_tasks}
          task_name={user_task.name}
          task_id={user_task.uid}
          business_key={user_task.business_key}
        >
        </.user_task_ref>
      </div>
      <div>
        <.task_form current_task={@current_task} />
        <.start_app_form current_app={@current_app} />
      </div>
    </div>
    """
  end

  def nav(assigns) do
    ~H"""
    <nav class="mb-5 border border-black bg-gray-50 dark:bg-gray-700">
      <div class="max-w-screen-xl px-4 py-3 mx-auto">
        <div class="flex items-center">
          <ul class="flex flex-row font-medium mt-0 space-x-8 rtl:space-x-reverse text-sm">
            <li>
              <button
                data-modal-target="process-start-modal"
                data-modal-toggle="process-start-modal"
                class="block text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
                type="button"
              >
                Start BPM Application
              </button>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    <.choose_bpm_application bpm_applications={@bpm_applications} />
    """
  end

  def choose_bpm_application(assigns) do
    ~H"""
    <div
      id="process-start-modal"
      tabindex="-1"
      aria-hidden="true"
      class="hidden overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 justify-center items-center w-full md:inset-0 h-[calc(100%-1rem)] max-h-full"
    >
      <div class="relative p-4 w-full max-w-md max-h-full">
        <!-- Modal content -->
        <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
          <!-- Modal header -->
          <div class="flex items-center justify-between p-4 md:p-5 border-b rounded-t dark:border-gray-600">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              Start an Application
            </h3>
            <button
              type="button"
              class="end-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white"
              data-modal-hide="process-start-modal"
            >
              <svg
                class="w-3 h-3"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 14 14"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                />
              </svg>
              <span class="sr-only">Close modal</span>
            </button>
          </div>
          <!-- Modal body -->
          <div class="p-4 md:p-5">
            <form phx-submit="set_current_app" class="max-w-sm mx-auto">
              <select
                id="app_name"
                name="app_name"
                class="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
              >
                <option selected>Choose an application</option>
                <option :for={app <- @bpm_applications} value={app.name}><%= app.name %></option>
              </select>
              <button
                data-modal-hide="process-start-modal"
                type="submit"
                class="mt-6 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
              >
                Start
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def user_task_ref(assigns) do
    ~H"""
    <a
      phx-click="toggle_current_task"
      phx-value-task-id={@task_id}
      href="#"
      class="block max-w-sm my-2 p-4 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
    >
      <h5 class="mb-2 text-lg font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @task_name %>
      </h5>
      <p class="font-normal text-sm text-gray-700 dark:text-gray-400">
        Business Key: <%= @business_key %>
      </p>
    </a>
    """
  end

  def task_form(assigns) do
    ~H"""
    <form :if={@current_task} phx-submit="complete_task" class="ml-8">
      <div class="grid grid-cols-3 gap-6">
        <.input_field :for={{name, value} <- @current_task.data} name={name} value={value} />
      </div>
      <div class="grid grid-cols-3 gap-6 mb-8">
        <.output_field :for={name <- @current_task.outputs} name={name} value="" />
      </div>
      <div class="flex gap-2 flex-row">
        <button
          type="submit"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm text-center px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Submit
        </button>
      </div>
    </form>
    """
  end

  def start_app_form(assigns) do
    ~H"""
    <form :if={@current_app} phx-submit="start_app" class="ml-8">
      <div class="grid grid-cols-3 gap-6 mb-8">
        <.output_field name="Business Key Prefix" value="" />
        <.output_field :for={field <- @current_app.data} name={field} value="" />
      </div>
      <div class="flex gap-2 flex-row">
        <button
          type="submit"
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm text-center px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Start Application
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
        name={@name}
        id="output"
        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        value={@value}
      />
    </div>
    """
  end

  def handle_event("toggle_current_task", %{"task-id" => task_id}, socket) do
    current_task = socket.assigns.current_task
    current_task =
      if current_task, do: nil, else: Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_id end)

    {:noreply, assign(socket, current_task: current_task, current_app: nil)}
  end

  def handle_event("complete_task", data, socket) do
    task_uid = socket.assigns.current_task.uid
    ProcessService.complete_user_task(task_uid, data)
    Process.sleep(500)
    user_tasks = ProcessService.get_user_tasks()
    {:noreply, assign(socket, user_tasks: user_tasks, current_task: nil)}
  end

  def handle_event("start_app", data, socket) do
    application = socket.assigns.current_app
    time = Timex.now() |> Timex.format!("{YYYY}-{0M}-{D}-{h24}-{m}-{s}")
    business_key_prefix = data["Business Key Prefix"]
    business_key =
      if business_key_prefix == "" do
        application.name <> "-" <> time
      else
        business_key_prefix <> "-" <> time
      end
    data = Map.delete(data, "Business Key Prefix")

    {:ok, ppid, _uid, _key} =
      ProcessEngine.start_process(application.main, data, business_key)

    ProcessEngine.execute(ppid)
    Process.sleep(500)
    user_tasks = ProcessService.get_user_tasks()
    {:noreply, assign(socket, user_tasks: user_tasks, current_task: nil, current_app: nil)}
  end

  def handle_event("set_current_app", %{"app_name" => application_name}, socket) do
    application =
      Enum.find(socket.assigns.bpm_applications, fn app -> app.name == application_name end)

    {:noreply, assign(socket, current_task: nil, current_app: application)}
  end
end
