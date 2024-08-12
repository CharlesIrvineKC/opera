defmodule Opera.Processes.HomeLoanApp do
  @moduledoc false
  use Mozart.BpmProcess

  def_bpm_application("Home Loan Process",
    main: "Home Loan",
    data: "First Name,Last Name,Income,Debt",
    bk_prefix: "Last Name, First Name"
  )

  def pre_approval_declined(data) do
    data["Pre Approval"] == "Declined"
  end

  def_choice_type("Pre Approval", choices: "Approved, Declined")
  def_choice_type("Loan Verified", choices: "Pass, Fail")
  def_choice_type("Loan Approved", choices: "Approved, Declined")

  defprocess "Home Loan" do
    user_task("Perform Pre-Approval", groups: "credit", outputs: "Pre Approval")

    reroute_task "Pre-Approval Denied", condition: :pre_approval_declined do
      user_task("Communicate Loan Denied", groups: "credit", outputs: "Communicate Loan Denied")
    end

    user_task("Receive Mortage Application", groups: "credit", outputs: "Purchase Price")
    user_task("Process Loan", groups: "credit", outputs: "Loan Verified")
    subprocess_task("Perform Loan Evaluation", model: "Perform Loan Evaluation Process")
  end

  def loan_failed_verification(data) do
    data["Loan Verified"] == "Fail"
  end

  defprocess "Perform Loan Evaluation Process" do
    reroute_task "Loan Failed Verification", condition: :loan_failed_verification do
      user_task("Communicate Loan Denied", groups: "credit", outputs: "Communicate Loan Denied")
    end

    user_task("Perform Underwriting", groups: "underwriting", outputs: "Loan Approved")
    subprocess_task("Route from Underwriting", model: "Route from Underwriting Process")
  end

  def loan_declined(data) do
    data["Loan Approved"] == "Declined"
  end

  def_choice_type("Communicate Loan Approved", choices: "By Phone, By US Mail")

  def_choice_type("Communicate Loan Denied", choices: "By Phone, By US Mail")

  defprocess "Route from Underwriting Process" do
    reroute_task "Loan Declined", condition: :loan_declined do
      user_task("Communicate Loan Denied",
        groups: "customer_service",
        outputs: "Communicate Loan Denied"
      )
    end

    user_task("Communicate Approval", groups: "credit", outputs: "Communicate Loan Approved")
  end
end
