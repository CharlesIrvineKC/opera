defmodule Opera.Processes.SendInvoices do
  @moduledoc false
  use Mozart.BpmProcess

  defprocess "Send Invoices" do
    prototype_task("Retrieve Purchases")
    prototype_task("Send Invoices")
  end
  
end
