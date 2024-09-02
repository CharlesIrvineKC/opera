defmodule OperaWeb.ProcessesLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService
  alias Mozart.ProcessEngine

  on_mount {OperaWeb.UserAuth, :ensure_authenticated}

  def mount(params, _session, socket) do
    process_state = case params do %{"process_state" => process_state} -> process_state; _ -> nil end

    bpm_modules = Application.fetch_env!(:opera, :process_apps)
    process_pids = Map.values(ProcessService.get_active_processes())

    active_processes =
      Enum.map(process_pids, fn pid -> ProcessEngine.get_state(pid) end)
      |> Enum.filter(fn p -> p.parent_uid == nil end)

    completed_processes =
      ProcessService.get_completed_processes()
      |> Enum.filter(fn p -> p.parent_uid == nil end)

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

  def nav(assigns) do
    ~H"""
    <nav class="mb-5 bg-gray-50 dark:bg-gray-700">
      <div class="max-w-screen-xl px-4 py-3 mx-auto">
        <div class="flex gap-4 items-center">
          <ul class="flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
            <li>
              <button
                id="applicationsNavBarLink"
                data-dropdown-toggle="applicationsNavBar"
                class="flex items-center justify-between w-full py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:w-auto dark:text-white md:dark:hover:text-blue-500 dark:focus:text-white dark:border-gray-700 dark:hover:bg-gray-700 md:dark:hover:bg-transparent"
              >
                Applications
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
                id="applicationsNavBar"
                class="z-10 hidden font-normal bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600"
              >
                <ul
                  class="py-2 text-sm text-gray-700 dark:text-gray-400"
                  aria-labelledby="dropdownLargeButton"
                >
                  <li>
                    <a
                      data-modal-target="load-application-modal"
                      data-modal-toggle="load-application-modal"
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                    >
                      Deploy an Application
                    </a>
                  </li>
                </ul>
              </div>
            </li>
          </ul>

          <ul class="flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
            <li>
              <button
                id="processesNavBarLink"
                data-dropdown-toggle="processesNavBar"
                class="flex items-center justify-between w-full py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:w-auto dark:text-white md:dark:hover:text-blue-500 dark:focus:text-white dark:border-gray-700 dark:hover:bg-gray-700 md:dark:hover:bg-transparent"
              >
                Processes
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
                id="processesNavBar"
                class="z-10 hidden font-normal bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600"
              >
                <ul
                  class="py-2 text-sm text-gray-700 dark:text-gray-400"
                  aria-labelledby="dropdownLargeButton"
                >
                  <li>
                    <a
                      phx-click="show-active-processes"
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                    >
                      Active Processes
                    </a>
                  </li>
                  <li>
                    <a
                      phx-click="show-completed-processes"
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                    >
                      Completed Processes
                    </a>
                  </li>
                </ul>
              </div>
            </li>
          </ul>

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
        </div>
      </div>
    </nav>
    <.choose_application bpm_modules={@bpm_modules} />
    """
  end

  def completed_process_instances(assigns) do
    ~H"""
    <div :if={@process_state == "completed_processes"}>
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
              :for={process <- @completed_processes}
              phx-click="show-process"
              phx-value-process-id={process.uid}
              class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
            >
              <td class="px-6 py-4">
                <%= process.model_name %>
              </td>
              <td class="px-6 py-4">
                <%= process.business_key %>
              </td>
              <td class="px-6 py-4">
                <%= Timex.format!(process.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}-{s}") %>
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
    <div :if={@process_state == "active_processes"}>
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
              :for={process <- @active_processes}
              phx-click="show-process"
              phx-value-process-id={process.uid}
              class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
            >
              <td class="px-6 py-4">
                <%= process.model_name %>
              </td>
              <td class="px-6 py-4">
                <%= process.business_key %>
              </td>
              <td class="px-6 py-4">
                <%= Timex.format!(process.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}-{s}") %>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def choose_application(assigns) do
    ~H"""
    <div
      id="load-application-modal"
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
              Deploy a BPM Application
            </h3>
            <button
              type="button"
              class="end-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white"
              data-modal-hide="load-application-modal"
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
            <form phx-submit="load-application" class="max-w-sm mx-auto">
              <div>
                <label
                  for="application_name"
                  class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
                >
                  BPM Application Module Name
                </label>
                <select
                  id="application"
                  name="application"
                  class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                >
                  <option selected>Choose a BPM application</option>
                  <option :for={{name, module} <- @bpm_modules} value={module}>
                    <%= name %>
                  </option>
                </select>
              </div>
              <button
                data-modal-hide="load-application-modal"
                type="submit"
                class="mt-6 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
              >
                Load
              </button>
            </form>
          </div>
        </div>
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
    process_state = socket.assigns.process_state

    processes =
      if process_state == "active_processes" do
        socket.assigns.active_processes
      else
        socket.assigns.completed_processes
      end

    selected_process =
      Enum.find(processes, fn ps -> ps.uid == process_uid end)

    {:noreply, redirect(socket, to: ~p"/processes/#{selected_process.uid}?process_state=#{process_state}")}
  end

  def handle_event("show-active-processes", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/processes?process_state=active_processes")}
  end

  def handle_event("show-completed-processes", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/processes?process_state=completed_processes")}
  end
end
