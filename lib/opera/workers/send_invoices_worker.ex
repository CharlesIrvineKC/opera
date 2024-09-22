defmodule Opera.Workers.SendInvoicesWorker do
  use Oban.Worker

  alias Mozart.ProcessEngine
  alias Mozart.ProcessService

  @impl Oban.Worker
  def perform(_job) do
    process_model = ProcessService.get_process_model("Send Invoices")

    if process_model do
      data = %{
        "Company Name" => "Acme Hardware",
        "Account Number" => "Acme 0001",
        "Amount" => "10000"
      }

      time = Timex.now() |> Timex.format!("{YYYY}-{0M}-{D}-{h24}-{m}-{s}")

      business_key = "Acme Hardware - 10000" <> "-" <> time

      {:ok, ppid, _uid, _key} =
        ProcessEngine.start_process(process_model, data, business_key)

      ProcessEngine.execute(ppid)
      :ok
    else
      IO.puts("Application Send Invoices is not loaded or defined.")
      :ok
    end
  end

  def get_business_key(process_data, application_prefix) do
    values = Enum.map(application_prefix, &Map.get(process_data, &1))
    Enum.reduce(values, &(&2 <> "-" <> &1))
  end
end
