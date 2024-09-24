defmodule Opera.Processes.ObanTimerTaskProcess do
  use Mozart.BpmProcess

  def_bpm_application("Oban Timer Process",
    data: "foobar",
    bk_prefix: "foobar")

  defprocess "Oban Timer Process" do
    timer_task("Wait One Minute", duration: 30, function: :schedule_oban_task)
  end

  def schedule_oban_task(task_uid, process_uid, duration) do
    %{"task_id" => task_uid, "process_uid" => process_uid}
    |> Opera.Processes.ObanTimerWorker.new(schedule_in: duration)
    |> Oban.insert()
  end
end
