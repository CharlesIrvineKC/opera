defmodule OperaWeb.TasksLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService, as: PS
  alias Mozart.ProcessEngine, as: PE

  alias OperaWeb.OperaComponents, as: OC
  alias OperaWeb.FormHelper, as: FH
  alias Opera.Accounts

  on_mount {OperaWeb.UserAuth, :ensure_authenticated}

  def mount(params, %{"user_token" => user_token}, socket) do
    task_uid =
      case params do
        %{"task_uid" => task_uid} -> task_uid
        _ -> nil
      end

    user_tasks = PS.get_user_tasks()

    bpm_applications =
      Enum.map(PS.get_bpm_applications(), fn {_k, v} -> v end)

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
      <div class="mt-8 min-w-72">
        <.user_task_ref :for={user_task <- @user_tasks} task={user_task}></.user_task_ref>
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
    <button
      id="startBpmAppButton"
      phx-click={JS.remove_class("hidden", to: "#dropdown")}
      phx-click-away={JS.add_class("hidden", to: "#dropdown")}
      class="ml-4 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      type="button"
    >
      Start Business Process
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
    <div class="relative ml-8">
      <div
        id="dropdown"
        class="z-10 hidden absolute top-1 bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
      >
        <ul
          id="dropDownList"
          class="py-2 text-sm text-gray-700 dark:text-gray-200"
          aria-labelledby="startBpmAppButton"
        >
          <li :for={app <- @bpm_applications}>
            <a
              href="#"
              phx-click={handle_select_app()}
              phx-value-app-name={app.name}
              class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
            >
              <%= app.name %>
            </a>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_select_app(js \\ %JS{}) do
    js
    |> JS.add_class("hidden", to: "#dropdown")
    |> JS.push("set_current_app")
  end

  def user_task_ref(assigns) do
    ~H"""
    <a
      phx-click="toggle_current_task"
      phx-value-task-id={@task.uid}
      href="#"
      class="block max-w-sm p-2 bg-white border border-gray-200 shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
    >
      <h5 class="text-md font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @task.name %>
      </h5>
      <h5 class="mb-2 text-sm font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @task.top_level_model_name %>
      </h5>
      <p class="font-normal text-sm text-gray-700 dark:text-gray-400">
        <%= @task.business_key %>
      </p>
      <p :if={@task.assigned_user} class="font-normal text-sm text-gray-700 dark:text-gray-400">
        Assignee: <%= @task.assigned_user %>
      </p>
    </a>
    """
  end

  def task_form(assigns) do
    ~H"""
    <form :if={@current_task} phx-submit="complete_task" class="ml-8">
      <h3 class="text-2xl mb-2 font-bold dark:text-white">
        <%= @current_task.name %> - <%= @current_task.top_level_model_name %>
      </h3>
      <div class="mb-4 flex justify-between">
        <span><%= @current_task.business_key %></span>
        <div>
          <button
            phx-click="toggle-claim"
            phx-value-task-id={@current_task.uid}
            type="button"
            class="px-3 py-2 text-xs font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            <.link href={~p"/processes/#{@current_task.process_uid}/?process_state=active"}>
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
      <div class="flex flex-row flex-wrap gap-6 mb-8">
        <OC.input_field
          :for={{name, value} <- FH.get_ordered_inputs(@current_task.module, @current_task.data)}
          name={name}
          value={value}
        />
      </div>
      <div class="flex flex-row flex-wrap gap-6 mb-8">
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
        <OC.output_field
          :for={field <- FH.get_ordered_outputs(@current_app.module, @current_app.data)}
          enabled={true}
          name={field}
          value=""
        />
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

    if current_task do
      {:noreply, redirect(socket, to: ~p"/tasks/#{current_task.uid}")}
    else
      {:noreply, redirect(socket, to: ~p"/tasks")}
    end

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

  def handle_event("set_current_app", %{"app-name" => application_name}, socket) do
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
