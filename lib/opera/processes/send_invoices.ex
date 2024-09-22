defmodule Opera.Processes.SendInvoices do
  @moduledoc false
  use Mozart.BpmProcess

  def_bpm_application("Send Invoices",
    data: "Company Name, Amount, Account Number",
    bk_prefix: "Company Name, Account Number"
  )

  defprocess "Send Invoices" do
    prototype_task("Retrieve Purchases")
    prototype_task("Send Invoices")
  end
end
