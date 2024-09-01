defmodule OperaWeb.ProcessLive do
  use OperaWeb, :live_view

  alias OperaWeb.OperaComponents, as: OC
  alias Mozart.ProcessEngine
  alias Mozart.ProcessService
  alias Timex.Duration

  def mount(%{"process_uid" => process_uid, "process_state" => process_state}, _session, socket) do
    process_pids = Map.values(ProcessService.get_active_processes())

    processes =
      if process_state == "active_processes" do
        Enum.map(process_pids, fn pid -> ProcessEngine.get_state(pid) end)
      else
        ProcessService.get_completed_processes()
      end

    selected_process = Enum.find(processes, fn ps -> ps.uid == process_uid end)
    subprocesses = Enum.filter(processes, fn p -> p.parent_uid == selected_process.uid end)

    socket =
      assign(socket,
        selected_process: selected_process,
        subprocesses: subprocesses,
        process_state: process_state,
        selected_task: nil
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="ml-10">
      <.process_header selected_process={@selected_process} />
      <hr class="h-1 mx-auto my-4 bg-gray-200 border-0 rounded md:my-10 dark:bg-gray-700" />
      <.subprocesses subprocesses={@subprocesses} process_state={@process_state} />
      <.tasks
        tasks={Map.values(@selected_process.open_tasks)}
        task_state="open"
        selected_task={@selected_task}
      />
      <.tasks
        tasks={@selected_process.completed_tasks}
        task_state="completed"
        selected_task={@selected_task}
      />
      <.task_state selected_task={@selected_task} process_state={@process_state}/>
      <hr :if={@selected_task} class="h-px my-8 bg-gray-200 border-2 dark:bg-gray-700">
      <.process_data selected_process={@selected_process} />
    </div>
    """
  end

  def process_header(assigns) do
    ~H"""
    <div class="">
      <h2 class="text-4xl mb-2 font-bold dark:text-white"><%= @selected_process.model_name %></h2>
      <h4 class="text-xl font-bold dark:text-white"><%= @selected_process.business_key %></h4>
    </div>
    """
  end

  def subprocesses(assigns) do
    ~H"""
    <div :if={@subprocesses != []}>
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
              phx-click="show-subprocess"
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

  def task_state(assigns) do
    ~H"""
    <div :if={@selected_task}>
    <h3 class="text-3xl mt-5 mb-5 font-bold dark:text-white">Task State: <%= @selected_task.name %></h3>
      <div class="flex flex-row flex-wrap gap-6 mb-8">
          <OC.input_field :for={{k,v} <- Map.from_struct(@selected_task)} name={k} value={v} />
      </div>
    </div>
    """
  end

  def process_data(assigns) do
    ~H"""
    <div :if={@selected_process}>
      <h3 class="text-3xl mt-5 mb-5 font-bold dark:text-white">Process Data</h3>
      <div class="flex flex-row flex-wrap gap-6 mb-8">
        <OC.input_field :for={{name, value} <- @selected_process.data} name={name} value={value} />
      </div>
    </div>
    """
  end

  def tasks(assigns) do
    ~H"""
    <div :if={@tasks != []}>
      <h3 class="text-3xl mt-5 font-bold dark:text-white">
        <%= if @task_state == "completed", do: "Completed ", else: "Open " %>Tasks
      </h3>
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
              <th :if={@task_state == "completed"} scope="col" class="px-6 py-3">
                Finish Time
              </th>
              <th :if={@task_state == "completed"} scope="col" class="px-6 py-3">
                Duration
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={task <- @tasks}
              phx-click="select-task" phx-value-task-uid={task.uid} phx-value-task-state={@task_state}
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
              <td :if={@task_state == "completed"} class="px-6 py-4">
                <%= Timex.format!(task.finish_time, "{YYYY}-{0M}-{D}-{h24}-{m}") %>
              </td>
              <td :if={@task_state == "completed"} class="px-6 py-4">
                <%= Duration.to_seconds(Duration.from_microseconds(task.duration), truncate: true) %> s
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <.modal id="user-modal">
        <h1>
          Foobar
        </h1>
      </.modal>
    </div>
    """
  end

  def get_completed_tasks(process) do
    Enum.filter(process.completed_tasks, fn t -> t.type != :case end)
  end

  def handle_event("show-subprocess", %{"process-id" => process_id}, socket) do
    process_state = socket.assigns.process_state
    {:noreply, redirect(socket, to: ~p"/processes/#{process_id}?process_state=#{process_state}")}
  end

  def handle_event("select-task", %{"task-uid" => task_uid, "task-state" => task_state}, socket) do
    process = socket.assigns.selected_process

    tasks =
      cond do
        task_state == "open" -> Map.values(process.open_tasks)
        task_state == "completed" -> process.completed_tasks
      end

    task = Enum.find(tasks, &(&1.uid == task_uid))

    {:noreply, assign(socket, :selected_task, task)}
  end
end
