defmodule Opera.Processes.HomeLoanApp do
  @moduledoc false
  use Mozart.BpmProcess

  def pre_approved(data) do
    data.pre_approval
  end

  def pre_approval_declined(data) do
    not data.pre_approval
  end

  defprocess "Home Loan" do
    user_task("Perform Pre-Approval", groups: "credit")
    case_task "Route on Pre-Approcal Completion" do
      case_i :pre_approved do
        user_task("Receive Mortage Application", groups: "credit")
        user_task("Process Loan", groups: "credit")
        subprocess_task("Perform Loan Evaluation", model: "Perform Loan Evaluation Process")
      end
      case_i :pre_approval_declined do
          user_task("Communicate Loan Denied", groups: "credit")
      end
    end
  end


def loan_verified(data) do
  data.loan_verified
end

def loan_failed_verification(data) do
  ! data.loan_verified
end

defprocess "Perform Loan Evaluation Process" do
  case_task "Process Loan Outcome" do
    case_i :loan_verified do
      user_task("Perform Underwriting", groups: "underwriting")
      subprocess_task("Route from Underwriting", model: "Route from Underwriting Process")
    end
    case_i :loan_failed_verification do
      user_task("Communicate Loan Denied", groups: "credit")
    end
  end
end

def loan_approved(data) do
  data.loan_approved
end

def loan_declined(data) do
  ! data.loan_approved
end

defprocess "Route from Underwriting Process" do
  case_task "Route from Underwriting" do
    case_i :loan_approved do
      user_task("Communicate Approcal", groups: "credit")
    end
    case_i :loan_declined do
      user_task("Communicate Loan Denied", groups: "customer_service")
    end
  end
end

end
