alias Mozart.ProcessEngine

Opera.Processes.HomeLoanApp.load()

customers = [
  %{"Name" => "John Doe", "Income" => 50_000, "Debt" => 10_000},
  %{"Name" => "Jane Doe", "Income" => 60_000, "Debt" => 10_000},
  %{"Name" => "Robert Smith", "Income" => 80_000, "Debt" => 10_000},
  %{"Name" => "Sallie Long", "Income" => 120_000, "Debt" => 10_000},
  %{"Name" => "Mary Winn", "Income" => 500_000, "Debt" => 10_000}
]

Enum.each(customers, fn customer ->
  {:ok, ppid, _uid, _key} = ProcessEngine.start_process("Home Loan", customer, customer["Name"])
  ProcessEngine.execute(ppid)
  Process.sleep(50)
end)
