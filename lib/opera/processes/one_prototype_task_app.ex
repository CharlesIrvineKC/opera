defmodule Opera.Processes.OnePrototypeTaskApp do
  use Mozart.BpmProcess

  def_bpm_application("One Prototype Task Process",
    main: "One Prototype Task Process", data: "")

  defprocess "One Prototype Task Process" do
    prototype_task "Prototype Task"
  end
end
