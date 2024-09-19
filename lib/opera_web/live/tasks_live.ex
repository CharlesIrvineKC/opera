defmodule OperaWeb.TasksLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService, as: PS
  alias Mozart.ProcessEngine, as: PE

  alias OperaWeb.OperaComponents, as: OC
  alias OperaWeb.FormHelper, as: FH
  alias Opera.Accounts

  on_mount {OperaWeb.UserAuth, :ensure_authenticated}

  def mount(_params, %{"user_token" => user_token}, socket) do
    user_tasks = PS.get_user_tasks()

    bpm_applications = Keyword.values(PS.get_bpm_applications())

    all_groups =
      Enum.map(bpm_applications, &(&1.groups))
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort(&(&1 < &2))

    user = Accounts.get_user_by_session_token(user_token)

    socket =
      assign(socket,
        user_tasks: user_tasks,
        bpm_applications: bpm_applications,
        current_app: nil,
        current_task: nil,
        filtered_app: nil,
        filtered_groups: [],
        all_groups: all_groups,
        assigned_to_me: false,
        assigned_to_my_groups: false,
        user: user,
        users_groups: get_users_groups(user)
      )

    {:ok, socket}
  end

  defp get_users_groups(_user), do: ["Underwriting", "Admin", "Management", "Credit"]

  def handle_params(%{"task_uid" => task_uid}, _uri, socket) do
    user_tasks = socket.assigns.user_tasks
    current_task = Enum.find(user_tasks, &(&1.uid == task_uid))
    {:noreply, assign(socket, current_task: current_task)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, current_task: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-8">
      <.nav bpm_applications={@bpm_applications} />
      <.set_filters
        bpm_applications={@bpm_applications}
        filtered_app={@filtered_app}
        all_groups={@all_groups}
      />
      <div class="flex flex-row">
        <div class="mt-2 mr-12 min-w-72">
          <.user_task_ref
            :for={user_task <- @user_tasks}
            :if={
              passes_filters(
                user_task,
                @filtered_app,
                @filtered_groups,
                @assigned_to_me,
                @assigned_to_my_groups,
                @user,
                @users_groups
              )
            }
            task={user_task}
          >
          </.user_task_ref>
        </div>
        <div>
          <.task_form current_task={@current_task} user={@user} />
          <.start_app_form current_app={@current_app} />
        </div>
      </div>
    </div>
    """
  end

  def passes_filters(
        user_task,
        filtered_app,
        filtered_groups,
        assigned_to_me,
        assigned_to_my_groups,
        user,
        users_groups
      ) do
    passes_app_filter(filtered_app, user_task) &&
      passes_user_filter(assigned_to_me, user, user_task) &&
      passes_group_filter(filtered_groups, user_task) &&
      passes_users_group_filter(assigned_to_my_groups, users_groups, user_task)
  end

  def passes_users_group_filter(assigned_to_my_groups, users_groups, user_task) do
    !assigned_to_my_groups ||
      user_has_group(user_task, users_groups)
  end

  def user_has_group(user_task, users_groups) do
      Enum.member?(users_groups, user_task.assigned_group)
  end

  def passes_app_filter(filtered_app, user_task) do
    !filtered_app || filtered_app.process == user_task.top_level_process
  end

  def passes_group_filter(filtered_groups, user_task) do
    filtered_groups == [] || Enum.member?(filtered_groups, user_task.assigned_group)
  end

  def passes_user_filter(assigned_to_me, user, user_task) do
    !assigned_to_me || user_task.assigned_user == user.email
  end

  def set_process_filter(assigns) do
    ~H"""
    <div>
      <button
        id="processFilterButton"
        phx-click={JS.remove_class("hidden", to: "#filter-process-dropdown")}
        phx-click-away={JS.add_class("hidden", to: "#filter-process-dropdown")}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-light text-xs px-3 py-1.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        type="button"
      >
        Filter Processes
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
        <div
          id="filter-process-dropdown"
          class="z-10 hidden absolute top-0 bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
        >
          <ul
            class="py-2 text-sm text-gray-700 dark:text-gray-200"
            aria-labelledby="processFilterButton"
          >
            <li>
              <a
                phx-click="filter-app"
                phx-value-filtered-app="All"
                href="#"
                class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
              >
                All
              </a>
            </li>
            <li :for={app <- @bpm_applications}>
              <a
                phx-click="filter-app"
                phx-value-filtered-app={app.process}
                href="#"
                class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
              >
                <%= app.process %>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  def set_groups_filter(assigns) do
    ~H"""
    <div>
      <button
        id="groupFilterButton"
        phx-click={JS.toggle_class("hidden", to: "#groupFilterCheckbox")}
        class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-light text-xs px-3 py-1.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        type="button"
      >
        Filter Groups
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
      <div class="absolute">
        <div
          id="groupFilterCheckbox"
          class="z-10 hidden top-0 w-48 bg-white divide-y divide-gray-100 rounded-lg shadow dark:bg-gray-700 dark:divide-gray-600"
        >
          <ul
            class="p-3 space-y-3 text-sm text-gray-700 dark:text-gray-200"
            aria-labelledby="groupFilterButton"
          >
            <li :for={group <- @all_groups}>
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
    """
  end

  def set_user_filter(assigns) do
    ~H"""
    <div class="flex items-center ml-4">
      <input
        id="assigned-to-me-cb"
        phx-click="toggle-assigned-to-me"
        type="checkbox"
        value=""
        class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
      />
      <label for="assigned-to-me-cb" class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">
        Assigned to Me
      </label>
    </div>
    """
  end

  def set_users_group_filter(assigns) do
    ~H"""
    <div class="flex items-center ml-4">
      <input
        id="assigned-to-my-groups-cb"
        phx-click="toggle-assigned-to-my-groups"
        type="checkbox"
        value=""
        class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
      />
      <label
        for="assigned-to-my-groups-cb"
        class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
      >
        Assigned to My Groups
      </label>
    </div>
    """
  end

  def set_filters(assigns) do
    ~H"""
    <div class="my-5 flex flex-row gap-2">
      <.set_process_filter bpm_applications={@bpm_applications} />
      <.set_groups_filter all_groups={@all_groups} />
      <.set_user_filter />
      <.set_users_group_filter />
    </div>
    """
  end

  def nav(assigns) do
    ~H"""
    <button
      id="startBpmAppButton"
      phx-click={JS.remove_class("hidden", to: "#dropdown")}
      phx-click-away={JS.add_class("hidden", to: "#dropdown")}
      class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
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
    <div class="relative">
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
              phx-value-app-name={app.process}
              class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
            >
              <%= app.process %>
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
      phx-value-task-uid={@task.uid}
      href="#"
      class="block max-w-sm p-2 bg-white border border-gray-200 shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
    >
      <h5 class="text-md font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @task.name %>
      </h5>
      <h5 class="mb-2 text-sm font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @task.top_level_process %>
      </h5>
      <p class="font-normal text-sm text-gray-700 dark:text-gray-400">
        <%= @task.business_key %>
      </p>
      <p class="font-normal text-sm text-gray-700 dark:text-gray-400">
        Group: <%= @task.assigned_group %>
      </p>
      <p :if={@task.assigned_user} class="font-normal text-sm text-gray-700 dark:text-gray-400">
        Assignee: <%= @task.assigned_user %>
      </p>
    </a>
    """
  end

  def task_form(assigns) do
    ~H"""
    <form :if={@current_task} phx-submit="complete_task">
      <h3 class="text-2xl mb-2 font-bold dark:text-white">
        <%= @current_task.name %> - <%= @current_task.top_level_process %>
      </h3>
      <div class="mb-4 flex justify-between">
        <span><%= @current_task.business_key %></span>
        <div>
          <button
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
            phx-value-task-uid={@current_task.uid}
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
    <form :if={@current_app} phx-submit="start_app">
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

  def handle_event("toggle-assigned-to-me", _params, socket) do
    {:noreply, assign(socket, :assigned_to_me, !socket.assigns.assigned_to_me)}
  end

  def handle_event("toggle-assigned-to-my-groups", _params, socket) do
    {:noreply, assign(socket, :assigned_to_my_groups, !socket.assigns.assigned_to_my_groups)}
  end

  def handle_event("select-group", %{"changed-group" => group, "value" => group}, socket) do
    filtered_groups = socket.assigns.filtered_groups
    {:noreply, assign(socket, :filtered_groups, [group | filtered_groups])}
  end

  def handle_event("select-group", %{"changed-group" => group}, socket) do
    filtered_groups = List.delete(socket.assigns.filtered_groups, group)
    {:noreply, assign(socket, :filtered_groups, filtered_groups)}
  end

  def handle_event("filter-app", %{"filtered-app" => filtered_app}, socket) do
    filtered_app =
      unless filtered_app == "All" do
        Enum.find(socket.assigns.bpm_applications, &(&1.process == filtered_app))
      end

    current_task = socket.assigns.current_task

    current_task =
      if current_task &&
           (filtered_app == nil || current_task.top_level_process == filtered_app.process),
         do: current_task

    socket =
      assign(socket,
        filtered_app: filtered_app,
        filtered_groups: [],
        current_task: current_task
      )

    {:noreply, socket}
  end

  def handle_event("toggle-claim", %{"task-uid" => task_uid}, socket) do
    task = Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_uid end)

    assignee =
      cond do
        task.assigned_user == socket.assigns.user.email ->
          nil

        task.assigned_user == nil ->
          socket.assigns.user.email
      end

    PS.assign_user_task(task_uid, assignee)

    task = Map.put(task, :assigned_user, assignee)

    user_tasks =
      Enum.map(socket.assigns.user_tasks, fn t -> if t.uid == task.uid, do: task, else: t end)

    {:noreply, assign(socket, current_task: task, user_tasks: user_tasks)}
  end

  def handle_event("toggle_current_task", %{"task-uid" => task_uid}, socket) do
    current_task = socket.assigns.current_task

    current_task =
      if current_task == nil do
        Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_uid end)
      else
        unless current_task.uid == task_uid do
          Enum.find(socket.assigns.user_tasks, fn t -> t.uid == task_uid end)
        end
      end

    if current_task do
      socket = assign(socket, current_task: current_task)
      {:noreply, push_patch(socket, to: ~p"/tasks/#{current_task.uid}")}
    else
      {:noreply, push_patch(socket, to: ~p"/tasks")}
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
      PE.start_process(application.process, data, business_key)

    PE.execute(ppid)
    Process.sleep(100)
    user_tasks = PS.get_user_tasks()
    {:noreply, assign(socket, user_tasks: user_tasks, current_task: nil, current_app: nil)}
  end

  def handle_event("set_current_app", %{"app-name" => application_name}, socket) do
    application =
      Enum.find(socket.assigns.bpm_applications, fn app -> app.process == application_name end)

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

  def get_business_key(input_map, key_list) do
    values = Enum.map(key_list, &Map.get(input_map, &1))
    Enum.reduce(values, &(&2 <> "-" <> &1))
  end
end
