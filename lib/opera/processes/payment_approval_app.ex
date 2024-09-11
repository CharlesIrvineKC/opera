defmodule Opera.Processes.PaymentApprovalApp do
  @moduledoc false
  use Mozart.BpmProcess

  def_bpm_application("Payment Approval Application",
    main: "Payment Approval Process",
    data: "Payment Amount, Customer Name",
    bk_prefix: "Customer Name"
  )

  def_choice_type("Ready for Approval", choices: "Yes, No")
  def_choice_type("Loan Approved (level one)", choices: "Approved, Declined")
  def_choice_type("Loan Approved (level two)", choices: "Approved, Declined")

  def level_one_approval_declined(data) do
    data["Loan Approved (level one)"] == "Declined"
  end

  def level_two_approval_declined(data) do
    data["Loan Approved (level two)"] == "Declined"
  end

  defprocess "Payment Approval Process" do
    user_task("Submit For Approval", group: "Accounts Payable", outputs: "Ready for Approval")
    user_task("Approve Payment (level one)", group: "Management", outputs: "Loan Approved (level one)")
    reroute_task "Level One Approval Declined", condition: :level_one_approval_declined do
      prototype_task("Handle Level One Approval Declined")
    end
    user_task("Approve Payment (level two)", group: "Management", outputs: "Loan Approved (level two)")
    reroute_task "Level Two Approval Declined", condition: :level_two_approval_declined do
      prototype_task("Handle Level Two Approval Declined")
    end
    prototype_task("Remit Payment")
  end
end
