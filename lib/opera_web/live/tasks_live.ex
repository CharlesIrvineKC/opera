defmodule OperaWeb.TasksLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService, as: PS
  alias Mozart.ProcessEngine, as: PE

  alias OperaWeb.OperaComponents, as: OC
  alias Opera.Accounts

  on_mount {OperaWeb.UserAuth, :ensure_authenticated}

  def mount(params, %{"user_token" => user_token}, socket) do
    task_uid =
      case params do
        %{"task-uid" => task_uid} -> task_uid
        _ -> nil
      end

    user_tasks = PS.get_user_tasks()
    bpm_applications = Enum.map(PS.get_bpm_applications(), fn {_k, v} -> v end)
    user = Accounts.get_user_by_session_token(user_token)
    current_task = if task_uid, do: Enum.find(user_tasks, &(&1.uid == task_uid))

    socket =
      assign(socket,
        user_tasks: user_tasks,
        bpm_applications: bpm_applications,
        current_task: current_task,
        current_app: nil,
        user: user
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.nav bpm_applications={@bpm_applications} />
    <div class="mx-10 flex flex-row">
      <div class="mr-6">
        <.user_task_ref
          :for={user_task <- @user_tasks}
          task_name={user_task.name}
          task_id={user_task.uid}
          business_key={user_task.business_key}
          assignee={user_task.assigned_user}
        >
        </.user_task_ref>
      </div>
      <div>
        <.task_form current_task={@current_task} user={@user} />
        <.start_app_form current_app={@current_app} />
      </div>
    </div>
    """
  end

  def nav(assigns) do
    ~H"""
    <nav class="mb-5 bg-gray-50 dark:bg-gray-700">
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
              Start an Business Process
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
        <%= @business_key %>
      </p>
      <p :if={@assignee} class="font-normal text-sm text-gray-700 dark:text-gray-400">
        Assignee: <%= @assignee %>
      </p>
    </a>
    """
  end

  def task_form(assigns) do
    ~H"""
    <form :if={@current_task} phx-submit="complete_task" class="ml-8">
      <h3 class="text-3xl mb-2 font-bold dark:text-white"><%= @current_task.name %></h3>
      <div class="mb-4 flex justify-between">
        <span><%= @current_task.business_key %></span>
        <div>
          <button
            phx-click="toggle-claim"
            phx-value-task-id={@current_task.uid}
            type="button"
            class="px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            <.link href={~p"/processes/#{@current_task.process_uid}/?process_state=active_processes"}>
              History
            </.link>
          </button>
          <button
            :if={@current_task.assigned_user == @user.email || @current_task.assigned_user == nil}
            phx-click="toggle-claim"
            phx-value-task-id={@current_task.uid}
            type="button"
            class="px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            <%= if @current_task.assigned_user == @user.email, do: "Release", else: "Claim" %>
          </button>
        </div>
      </div>
      <div class="mb-6 grid grid-cols-3 gap-6">
        <OC.input_field :for={{name, value} <- @current_task.data} name={name} value={value} />
      </div>
      <div class="grid grid-cols-3 gap-6 mb-4">
        <OC.output_field
          :for={name <- @current_task.outputs}
          name={name}
          enabled={@current_task.assigned_user}
          value=""
        />
      </div>
      <div :if={@current_task.assigned_user == @user.email} class="flex gap-2 flex-row">
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
      <div class="grid grid-cols-3 gap-6 mb-4">
        <OC.output_field :for={field <- @current_app.data} enabled={true} name={field} value="" />
      </div>
      <div class="mt-8 flex gap-2 flex-row">
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

  def handle_event("toggle-claim", %{"task-id" => task_id}, socket) do
    task = Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_id end)

    assignee =
      cond do
        task.assigned_user == socket.assigns.user.email ->
          nil

        task.assigned_user == nil ->
          socket.assigns.user.email
      end

    PS.assign_user_task(task_id, assignee)

    task = Map.put(task, :assigned_user, assignee)

    user_tasks =
      Enum.map(socket.assigns.user_tasks, fn t -> if t.uid == task.uid, do: task, else: t end)

    {:noreply, assign(socket, current_task: task, user_tasks: user_tasks)}
  end

  def handle_event("toggle_current_task", %{"task-id" => task_id}, socket) do
    current_task = socket.assigns.current_task

    current_task =
      if current_task == nil do
        Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_id end)
      else
        unless current_task.uid == task_id do
          Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_id end)
        end
      end

    {:noreply, assign(socket, current_task: current_task, current_app: nil)}
  end

  def handle_event("complete_task", data, socket) do
    task_uid = socket.assigns.current_task.uid
    business_key = socket.assigns.current_task.business_key
    PS.complete_user_task(task_uid, data)
    Process.sleep(100)
    user_tasks = PS.get_user_tasks()
    current_task = Enum.find(user_tasks, fn t -> t.business_key == business_key end)
    {:noreply, assign(socket, user_tasks: user_tasks, current_task: current_task)}
  end

  def handle_event("start_app", data, socket) do
    application = socket.assigns.current_app
    time = Timex.now() |> Timex.format!("{YYYY}-{0M}-{D}-{h24}-{m}-{s}")
    business_key = get_business_key(data, application.bk_prefix) <> "-" <> time

    data = convert_number_types(data)

    {:ok, ppid, _uid, _key} =
      PE.start_process(application.main, data, business_key)

    PE.execute(ppid)
    Process.sleep(100)
    user_tasks = PS.get_user_tasks()
    {:noreply, assign(socket, user_tasks: user_tasks, current_task: nil, current_app: nil)}
  end

  def handle_event("set_current_app", %{"app_name" => application_name}, socket) do
    application =
      Enum.find(socket.assigns.bpm_applications, fn app -> app.name == application_name end)

    {:noreply, assign(socket, current_task: nil, current_app: application)}
  end

  def convert_number_types(data_map) do
    Enum.reduce(data_map, %{}, fn {k, v}, acc ->
      type = PS.get_type(k)

      if type && type.type == :number do
        Map.put(acc, k, String.to_integer(v))
      else
        Map.put(acc, k, v)
      end
    end)
  end

  defp get_business_key(_data, []), do: ""
  defp get_business_key(data, [head]), do: data[head]

  defp get_business_key(data, [head | rest]),
    do: data[head] <> "-" <> get_business_key(data, rest)
end
