defmodule Opera.Processes.ObanTimerTaskProcess do
  use Mozart.BpmProcess

  def_bpm_application("Oban Timer Process")

  defprocess "Oban Timer Process" do
    timer_task("Wait One Minute", duration: 60, function: :schedule_oban_task)
  end

  def schedule_oban_task(task_uid, process_uid, duration) do
    %{"task_id" => task_uid, "process_uid" => process_uid}
    |> Opera.Workers.ObanTimerWorker.new(schedule_in: duration)
    |> Oban.insert()
  end
end
