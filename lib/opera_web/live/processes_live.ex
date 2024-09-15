defmodule OperaWeb.ProcessesLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService
  alias Mozart.ProcessEngine

  on_mount {OperaWeb.UserAuth, :ensure_authenticated}

  def mount(params, _session, socket) do
    process_state =
      case params do
        %{"process_state" => process_state} -> process_state
        _ -> nil
      end

    bpm_modules = Application.fetch_env!(:opera, :process_apps)
    process_pids = Map.values(ProcessService.get_active_processes())

    active_processes =
      Enum.map(process_pids, fn pid -> ProcessEngine.get_state(pid) end)
      |> Enum.filter(fn p -> p.parent_uid == nil end)
      |> Enum.sort(&Timex.before?(&1.start_time, &2.start_time))

    completed_processes =
      ProcessService.get_completed_processes()
      |> Enum.filter(fn p -> p.parent_uid == nil end)
      |> Enum.sort(&Timex.before?(&1.start_time, &2.start_time))

    selected_process = nil

    {:ok,
     assign(socket,
       bpm_modules: bpm_modules,
       active_processes: active_processes,
       completed_processes: completed_processes,
       process_state: process_state,
       selected_process: selected_process
     )}
  end

  def render(assigns) do
    ~H"""
    <.nav
      bpm_modules={@bpm_modules}
      active_processes={@active_processes}
      completed_processes={@completed_processes}
      selected_process={@selected_process}
      process_state={@process_state}
    />
    <.control_panel process_state={@process_state} />
    <.active_process_instances
      active_processes={@active_processes}
      selected_process={@selected_process}
      process_state={@process_state}
    />
    <.completed_process_instances
      completed_processes={@completed_processes}
      selected_process={@selected_process}
      process_state={@process_state}
    />
    """
  end

  def control_panel(assigns) do
    ~H"""
    <ul class="border-2 border--gray-600 ml-3 mb-5 items-center w-full text-sm font-medium text-gray-900 bg-white sm:flex dark:bg-gray-700 dark:border-gray-600 dark:text-white">
      <li class="">
        <div class="flex items-center ps-3">
          <input
            id="horizontal-list-radio-license"
            phx-click="show-active-processes"
            type="radio"
            value="active"
            checked={@process_state == "active"}
            name="list-radio"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-700 dark:focus:ring-offset-gray-700 focus:ring-2 dark:bg-gray-600 dark:border-gray-500"
          />
          <label
            for="horizontal-list-radio-license"
            class="w-full py-3 ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
          >
            Active
          </label>
        </div>
      </li>
      <li class="">
        <div class="flex items-center ps-3">
          <input
            id="horizontal-list-radio-id"
            phx-click="show-completed-processes"
            type="radio"
            value="completed"
            checked={@process_state == "complete"}
            name="list-radio"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-700 dark:focus:ring-offset-gray-700 focus:ring-2 dark:bg-gray-600 dark:border-gray-500"
          />
          <label
            for="horizontal-list-radio-id"
            class="w-full py-3 ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
          >
            Completed
          </label>
        </div>
      </li>
      <li class="">
        <div class="flex items-center ps-3">
          <input
            id="horizontal-list-radio-military"
            phx-click="show-all-processes"
            type="radio"
            value="all"
            checked={@process_state == nil}
            name="list-radio"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-700 dark:focus:ring-offset-gray-700 focus:ring-2 dark:bg-gray-600 dark:border-gray-500"
          />
          <label
            for="horizontal-list-radio-military"
            class="w-full py-3 ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
          >
            All
          </label>
        </div>
      </li>
    </ul>
    """
  end

  def load_bpm_app_dropdown(assigns) do
    ~H"""
    <ul class="flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
      <li>
        <button
          id="applicationsNavBarLink"
          phx-click={JS.remove_class("hidden", to: "#applicationsNavBar")}
          phx-click-away={JS.add_class("hidden", to: "#applicationsNavBar")}
          class="flex items-center justify-between w-full py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:w-auto dark:text-white md:dark:hover:text-blue-500 dark:focus:text-white dark:border-gray-700 dark:hover:bg-gray-700 md:dark:hover:bg-transparent"
        >
          Load BPM Application
          <svg
            class="w-2.5 h-2.5 ms-2.5"
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
          id="applicationsNavBar"
          class="z-10 absolute top-0 hidden font-normal bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600"
        >
          <ul
            class="py-2 text-sm text-gray-700 dark:text-gray-400"
            aria-labelledby="dropdownLargeButton"
          >
            <li :for={{name, module} <- @bpm_modules}>
              <a
                phx-click={load_app()}
                phx-value-application={module}
                href="#"
                class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
              >
                <%= name %>
              </a>
            </li>
          </ul>
        </div>
        </div>
      </li>
    </ul>
    """
  end

  def load_app(js \\ %JS{}) do
    js
    |> JS.add_class("hidden", to: "#applicationsNavBar")
    |> JS.push("load-application")
  end

  def admin_dropdown(assigns) do
    ~H"""
    <ul class="flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
      <li>
        <button
          id="adminNavBarLink"
          data-dropdown-toggle="adminNavBar"
          class="flex items-center justify-between w-full py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:w-auto dark:text-white md:dark:hover:text-blue-500 dark:focus:text-white dark:border-gray-700 dark:hover:bg-gray-700 md:dark:hover:bg-transparent"
        >
          Admin
          <svg
            class="w-2.5 h-2.5 ms-2.5"
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
        <div
          id="adminNavBar"
          class="z-10 hidden font-normal bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600"
        >
          <ul
            class="py-2 text-sm text-gray-700 dark:text-gray-400"
            aria-labelledby="dropdownLargeButton"
          >
            <li>
              <a
                phx-click="clear-databases"
                href="#"
                class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
              >
                Clear Databases
              </a>
            </li>
          </ul>
        </div>
      </li>
    </ul>
    """
  end

  def nav(assigns) do
    ~H"""
    <nav class="bg-gray-50 dark:bg-gray-700">
      <div class="max-w-screen-xl px-4 py-3 mx-auto">
        <div class="flex gap-4 items-center">
          <.load_bpm_app_dropdown bpm_modules={@bpm_modules}/>
          <.admin_dropdown />
        </div>
      </div>
    </nav>
    """
  end

  def completed_process_instances(assigns) do
    ~H"""
    <div
      :if={@completed_processes != [] && (@process_state == "complete" || @process_state == nil)}
      class="mt-6"
    >
      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <h3 class="text-3xl ml-5 font-bold dark:text-white">Completed Processes</h3>
        <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="px-6 py-3">
                Process Name
              </th>
              <th scope="col" class="px-6 py-3">
                Business Key
              </th>
              <th scope="col" class="px-6 py-3">
                Start Time
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={completed_process <- @completed_processes}
              phx-click="show-process"
              phx-value-process-id={completed_process.uid}
              class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
            >
              <td class="px-6 py-4">
                <%= completed_process.process %>
              </td>
              <td class="px-6 py-4">
                <%= completed_process.business_key %>
              </td>
              <td class="px-6 py-4">
                <%= Timex.format!(completed_process.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}-{s}") %>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def active_process_instances(assigns) do
    ~H"""
    <div :if={@active_processes != [] && (@process_state == "active" || @process_state == nil)}>
      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <h3 class="text-3xl ml-5 font-bold dark:text-white">Active Processes</h3>
        <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="px-6 py-3">
                Process Name
              </th>
              <th scope="col" class="px-6 py-3">
                Business Key
              </th>
              <th scope="col" class="px-6 py-3">
                Start Time
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={active_process <- @active_processes}
              phx-click="show-process"
              phx-value-process-id={active_process.uid}
              class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
            >
              <td class="px-6 py-4">
                <%= active_process.process %>
              </td>
              <td class="px-6 py-4">
                <%= active_process.business_key %>
              </td>
              <td class="px-6 py-4">
                <%= Timex.format!(active_process.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}-{s}") %>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def handle_event("load-application", %{"application" => module_name}, socket) do
    module = Module.concat(Elixir, String.to_atom(module_name))
    apply(module, :load, [])
    {:noreply, socket}
  end

  def handle_event("clear-databases", _params, socket) do
    ProcessService.clear_state()
    {:noreply, redirect(socket, to: ~p"/processes")}
  end

  def handle_event("show-process", %{"process-id" => process_uid}, socket) do
    processes = socket.assigns.active_processes ++ socket.assigns.completed_processes

    selected_process =
      Enum.find(processes, fn ps -> ps.uid == process_uid end)

    process_state = if selected_process.complete, do: "complete", else: "active"

    {:noreply,
     redirect(socket, to: ~p"/processes/#{selected_process.uid}?process_state=#{process_state}")}
  end

  def handle_event("show-active-processes", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/processes?process_state=active")}
  end

  def handle_event("show-all-processes", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/processes")}
  end

  def handle_event("show-completed-processes", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/processes?process_state=complete")}
  end
end
