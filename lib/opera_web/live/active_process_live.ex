defmodule OperaWeb.ActiveProcessLive do
  use OperaWeb, :live_view

  alias OperaWeb.OperaComponents, as: OC
  alias Mozart.ProcessEngine
  alias Mozart.ProcessService
  alias Timex.Duration

  def mount(%{"process_uid" => process_uid}, _session, socket) do
    process_pids = Map.values(ProcessService.get_active_processes())
    active_processes = Enum.map(process_pids, fn pid -> ProcessEngine.get_state(pid) end)
    selected_process = Enum.find(active_processes, fn ps -> ps.uid == process_uid end)
    subprocesses = Enum.filter(active_processes, fn p -> p.parent_uid == selected_process.uid end)
    socket = assign(socket, selected_process: selected_process, subprocesses: subprocesses)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="ml-10">
      <.process_header selected_process={@selected_process} />
      <hr class="h-1 mx-auto my-4 bg-gray-200 border-0 rounded md:my-10 dark:bg-gray-700">
      <.subprocesses subprocesses={@subprocesses}/>
      <.tasks selected_process={@selected_process} />
      <.process_data selected_process={@selected_process} />
    </div>
    """
  end

  def process_header(assigns) do
    ~H"""
    <div class="">
      <h2 class="text-4xl font-bold dark:text-white"><%= @selected_process.model_name %></h2>
      <h4 class="text-2xl font-bold dark:text-white"><%= @selected_process.business_key %></h4>
    </div>
    """
  end

  def subprocesses(assigns) do
    ~H"""
    <div>
      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <h3 class="text-3xl font-bold dark:text-white">Subprocesses</h3>
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
              :for={process <- @subprocesses}
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
    </div>
    """
  end

  def process_data(assigns) do
    ~H"""
    <div :if={@selected_process}>
      <h3 class="text-3xl mt-5 mb-5 font-bold dark:text-white">Process Data</h3>
      <div class="grid grid-cols-3 gap-6 mb-8">
        <OC.input_field :for={{name, value} <- @selected_process.data} name={name} value={value} />
      </div>
    </div>
    """
  end

  def open_tasks(assigns) do
    ~H"""
    <h3 class="text-3xl mt-5 font-bold dark:text-white">Open Tasks</h3>
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
    <h3 class="text-3xl mt-5 font-bold dark:text-white">Completed Tasks</h3>
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
    ~H"""
    <div :if={@selected_process}>
      <.open_tasks selected_process={@selected_process} />
      <.completed_tasks selected_process={@selected_process} />
    </div>
    """
  end
end
