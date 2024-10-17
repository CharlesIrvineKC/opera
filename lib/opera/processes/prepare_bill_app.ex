defmodule Opera.Processes.PrepareBillApp do
  @moduledoc false
  use Mozart.BpmProcess

  def_bpm_application("Prepare Bill",
    data: "amount, Customer Name, cust_type",
    bk_prefix: "Customer Name"
  )

  def_number_type("amount", min: 0, max: 1000000)
  def_choice_type("cust_type", choices: "Preferred, Basic")

  rule_table = """
  F       amount (integer)      cust_type (string)      ||      discount (integer)
  1        < 500                                        ||        0
  2        < 999                Preferred               ||        3
  3        < 999                Basic                   ||        2
  4        < 1500               Preferred               ||        4
  5       < 1500                Basic                   ||        3
  6        > 2000               Preferred               ||        5
  7        > 2000               Basic                   ||        4
  """

  defprocess "Prepare Bill" do
    rule_task("Discount Decision", inputs: "amount,cust_type", rule_table: rule_table)
    user_task("Create and Send Bill", group: "Billing", outputs: "Discounted Amount")
  end
end
