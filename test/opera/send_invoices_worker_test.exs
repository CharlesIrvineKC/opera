defmodule Opera.SendInvoicesWorkerTest do
  use ExUnit.Case

  alias Opera.Workers.SendInvoicesWorker, as: Worker
  alias Mozart.ProcessEngine
  alias Mozart.ProcessService

  test "get application" do
    process = ProcessService.get_process_model("Send Invoices")
    assert process != nil
  end

  test "get business key" do
    process_model = ProcessService.get_process_model("Send Invoices")

    data = %{
      "Company Name" => "Acme Hardware",
      "Account Number" => "Acme 0001",
      "Amount" => "10000"
    }

    time = Timex.now() |> Timex.format!("{YYYY}-{0M}-{D}-{h24}-{m}-{s}")

    business_key = "Acme Hardware - 10000 - " <> time

    {:ok, ppid, _uid, _key} =
      ProcessEngine.start_process(process_model, data, business_key)

    ProcessEngine.execute(ppid)
  end
end
