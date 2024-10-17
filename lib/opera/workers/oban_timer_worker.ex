defmodule Opera.Workers.ObanTimerWorker do
  use Oban.Worker, queue: :default, max_attempts: 5

  alias Mozart.ProcessService

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"process_uid" => process_uid,"task_id" => task_uid}}) do
    ppid = ProcessService.get_process_pid_from_uid(process_uid)
    send(ppid, {:timer_expired, task_uid})
    :ok
  end
end
