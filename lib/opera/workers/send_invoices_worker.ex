defmodule Opera.Workers.SendInvoicesWorker do
  use Oban.Worker

  alias Mozart.ProcessEngine
  alias Mozart.ProcessService

  @impl Oban.Worker
  def perform(_job) do
    application = ProcessService.get_bpm_application("Send Invoices")

    if application do
      data = %{
        "Company Name" => "Acme Hardware",
        "Account Number" => "Acme 0001",
        "Amount" => "10000"
      }

      time = Timex.now() |> Timex.format!("{YYYY}-{0M}-{D}-{h24}-{m}-{s}")

      business_key = get_business_key(data, application.bk_prefix) <> "-" <> time

      {:ok, ppid, _uid, _key} =
        ProcessEngine.start_process(application.process, data, business_key)

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
