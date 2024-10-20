defmodule Opera.Processes.HomeLoanApp do
  @moduledoc false
  use Mozart.BpmProcess

  def_bpm_application("Home Loan",
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
    user_task("Perform Pre-Approval",
      group: "Credit",
      outputs: "Pre Approval",
      documentation: """
      Check all documents for adherence to bank loan standards. Grant pre-approval only
      if there are no discrepancies.
      """
    )

    reroute_task "Pre-Approval Denied", condition: :pre_approval_declined do
      user_task("Communicate Loan Denied",
        group: "Credit",
        outputs: "Communicate Loan Denied",
        documentation:
          "Contact the loan applicant and inform them that the loan application has been declined."
      )
    end

    user_task("Receive Mortage Application",
      group: "Credit",
      outputs: "Purchase Price",
      documentation: "Accept and route the loan application to the processing department."
    )

    user_task("Process Loan",
      group: "Credit",
      outputs: "Loan Verified",
      documentation:
        "Process the loan application documentation so that the application can be turned over to the underwriting deppartment."
    )

    subprocess_task("Perform Loan Evaluation", process: "Perform Loan Evaluation Process")
  end

  def loan_failed_verification(data) do
    data["Loan Verified"] == "Fail"
  end

  defprocess "Perform Loan Evaluation Process" do
    reroute_task "Loan Failed Verification", condition: :loan_failed_verification do
      user_task("Communicate Loan Denied", group: "Credit", outputs: "Communicate Loan Denied",
      documentation: "Communicate with the applicant to inform them that the loan has been declined.")
    end

    user_task("Perform Underwriting", group: "Underwriting", outputs: "Loan Approved",
    documentation: "Perform home loan underwriting.")
    subprocess_task("Route from Underwriting", process: "Route from Underwriting Process")
  end

  def loan_declined(data) do
    data["Loan Approved"] == "Declined"
  end

  def_choice_type("Communicate Loan Approved", choices: "By Phone, By US Mail")

  def_choice_type("Communicate Loan Denied", choices: "By Phone, By US Mail")

  defprocess "Route from Underwriting Process" do
    reroute_task "Loan Declined", condition: :loan_declined do
      user_task("Communicate Loan Denied",
        group: "Customer Service",
        outputs: "Communicate Loan Denied",
        documentation: "Communicate with the applicant to inform them that the loan has been declined."
      )
    end

    user_task("Communicate Approval", group: "Credit", outputs: "Communicate Loan Approved",
    documentation: "Commuicate to the loan applicant that the loan has been approved.")
  end
end
