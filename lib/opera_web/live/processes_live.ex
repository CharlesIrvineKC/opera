defmodule OperaWeb.ProcessesLive do
  use OperaWeb, :live_view

  alias Mozart.ProcessService
  alias Mozart.ProcessEngine
  alias Timex.Duration
  alias OperaWeb.OperaComponents, as: OC

  def mount(_params, _session, socket) do
    bpm_modules = Application.fetch_env!(:opera, :process_apps)
    process_pids = Map.values(ProcessService.get_active_processes())
    active_processes = Enum.map(process_pids, fn pid -> ProcessEngine.get_state(pid) end)
    completed_processes = ProcessService.get_completed_processes()
    view = nil
    selected_process = nil

    {:ok,
     assign(socket,
       bpm_modules: bpm_modules,
       active_processes: active_processes,
       completed_processes: completed_processes,
       view: view,
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
      view={@view}
    />
    <.active_process_instances
      active_processes={@active_processes}
      selected_process={@selected_process}
      view={@view}
    />
    <.completed_process_instances
      completed_processes={@completed_processes}
      selected_process={@selected_process}
      view={@view}
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
        </div>
      </div>
    </nav>
    <.choose_application bpm_modules={@bpm_modules} />
    """
  end

  def completed_process_instances(assigns) do
    ~H"""
    <div :if={@view == :completed_processes}>
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
              phx-click="show-tasks"
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
                <%= Timex.format!(process.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}") %>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <.tasks selected_process={@selected_process} view={@view} />
      <.process_data selected_process={@selected_process} />
    </div>
    """
  end

  def active_process_instances(assigns) do
    ~H"""
    <div :if={@view == :active_processes}>
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
              phx-click="show-tasks"
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
                <%= Timex.format!(process.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}") %>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <.tasks selected_process={@selected_process} view={@view} />
      <.process_data selected_process={@selected_process} />
    </div>
    """
  end

  def process_data(assigns) do
    ~H"""
    <div :if={@selected_process}>
      <h3 class="text-3xl ml-5 mt-5 mb-5 font-bold dark:text-white">Process Data</h3>
      <div class="ml-5 grid grid-cols-3 gap-6 mb-8">
        <OC.input_field :for={{name, value} <- @selected_process.data} name={name} value={value} />
      </div>
    </div>
    """
  end

  def open_tasks(assigns) do
    ~H"""
    <h3 class="text-3xl ml-5 mt-5 font-bold dark:text-white">Open Tasks</h3>
    <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="px-6 py-3">
              Task Name
            </th>
            <th scope="col" class="px-6 py-3">
              Task Type
            </th>
            <th scope="col" class="px-6 py-3">
              Start Time
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={task <- Map.values(@selected_process.open_tasks)}
            class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
          >
            <td class="px-6 py-4">
              <%= task.name %>
            </td>
            <td class="px-6 py-4">
              <%= task.type %>
            </td>
            <td class="px-6 py-4">
              <%= Timex.format!(task.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}") %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def completed_tasks(assigns) do
    ~H"""
    <h3 class="text-3xl ml-5 mt-5 font-bold dark:text-white">Completed Tasks</h3>
    <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="px-6 py-3">
              Task Name
            </th>
            <th scope="col" class="px-6 py-3">
              Task Type
            </th>
            <th scope="col" class="px-6 py-3">
              Start Time
            </th>
            <th scope="col" class="px-6 py-3">
              Finish Time
            </th>
            <th scope="col" class="px-6 py-3">
              Duration
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={task <- @selected_process.completed_tasks}
            class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600"
          >
            <td class="px-6 py-4">
              <%= task.name %>
            </td>
            <td class="px-6 py-4">
              <%= task.type %>
            </td>
            <td class="px-6 py-4">
              <%= Timex.format!(task.start_time, "{YYYY}-{0M}-{D}-{h24}-{m}") %>
            </td>
            <td class="px-6 py-4">
              <%= Timex.format!(task.finish_time, "{YYYY}-{0M}-{D}-{h24}-{m}") %>
            </td>
            <td class="px-6 py-4">
              <%= Duration.to_seconds(Duration.from_microseconds(task.duration), truncate: true) %> s
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def tasks(assigns) do
    IO.inspect(assigns, label: "** assigns in tasks **")

    ~H"""
    <div :if={@selected_process}>
      <.open_tasks :if={@view == :active_processes} selected_process={@selected_process} />
      <.completed_tasks selected_process={@selected_process} />
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

  def handle_event("show-tasks", %{"process-id" => process_uid}, socket) do
    view = socket.assigns.view

    processes =
      if view == :active_processes do
        socket.assigns.active_processes
      else
        socket.assigns.completed_processes
      end

    selected_process =
      Enum.find(processes, fn ps -> ps.uid == process_uid end)

    {:noreply, assign(socket, selected_process: selected_process)}
  end

  def handle_event("show-active-processes", _params, socket) do
    {:noreply, assign(socket, view: :active_processes)}
  end

  def handle_event("show-completed-processes", _params, socket) do
    {:noreply, assign(socket, view: :completed_processes)}
  end
end
