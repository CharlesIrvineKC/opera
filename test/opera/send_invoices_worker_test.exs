defmodule Opera.SendInvoicesWorkerTest do
  use ExUnit.Case

  alias Opera.Workers.SendInvoicesWorker, as: Worker
  alias Mozart.ProcessEngine
  alias Mozart.ProcessService

  test "get application" do
    application = ProcessService.get_bpm_application("Send Invoices")
    assert application != nil
  end

  test "get business key" do
    application = ProcessService.get_bpm_application("Send Invoices")

    data = %{
      "Company Name" => "Acme Hardware",
      "Account Number" => "Acme 0001",
      "Amount" => "10000"
    }
    time = Timex.now() |> Timex.format!("{YYYY}-{0M}-{D}-{h24}-{m}-{s}")

    business_key = Worker.get_business_key(data, application.bk_prefix) <> "-" <> time

    assert business_key != nil
  end
end
