defmodule Opera.Processes.InvoiceReceipt do
  use Mozart.BpmProcess

  def_bpm_application("Invoice Receipt",
    data: "First Name,Last Name",
    bk_prefix: "Last Name, First Name"
  )

  def_choice_type("Invoice Approved?", choices: "Approved, Send to Review")
  def_choice_type("Invoice Review Determination", choices: "Rejected, Send to Approval")

  def invoice_approved(data) do
    data["Invoice Approved?"] == "Approved"
  end

  def invoice_sent_to_review(data) do
    data["Invoice Approved?"] == "Send to Review"
  end

  def invoice_not_rejected(data) do
    data["Invoice Review Determination"] != "Rejected"
  end

  def negotiation_not_resolved(data) do
    data["Invoice Review Determination"] != "Rejected" &&
      data["Invoice Approved?"] != "Approved"
  end

  defprocess "Invoice Receipt" do
    prototype_task("Assign Approver Group")
    user_task("Approve Invoice", group: "Admin", outputs: "Invoice Approved?")

    case_task "Approve Invoice Result" do
      case_i :invoice_approved do
        subprocess_task("Perform Bank Transfer SubTask", process: "Perform Bank Transfer")
      end

      case_i :invoice_sent_to_review do
        subprocess_task("Perform Invoice Approval Negotiation Subprocess",
          process: "Perform Invoice Approval Negotiation"
        )
      end
    end
  end

  def_confirm_type("Bank Transfer Prepared")
  def_confirm_type("Invoice Archived")

  defprocess "Perform Bank Transfer" do
    parallel_task "Post Approval Activities" do
      route do
        user_task("Prepare Bank Transfer", group: "Back Office", outputs: "Bank Transfer Prepared")
      end

      route do
        user_task("Archive Invoice", group: "Back Office", outputs: "Invoice Archived")
      end
    end
  end

  defprocess "Perform Invoice Approval Negotiation" do
    repeat_task "Invoice Approval Negotiation", condition: :negotiation_not_resolved do
      subprocess_task("Review Invoice Subprocess", process: "Review Invoice Process")

      conditional_task "Reapprove if not Rejected", condition: :invoice_not_rejected do
        user_task("Reapprove Invoice", group: "Admin", outputs: "Invoice Approved?")
      end
    end

    conditional_task "Negotiation Result", condition: :invoice_approved do
      subprocess_task("Perform Bank Transfer SubTask", process: "Perform Bank Transfer")
    end
  end

  def assign_user(user_task, data) do
    Map.put(user_task, :assigned_user, data["Invoice Reviewer ID"])
  end

  defprocess "Review Invoice Process" do
    user_task("Assign Reviewer", group: "Admin", outputs: "Invoice Reviewer ID")

    user_task("Review Invoice",
      group: "Admin",
      outputs: "Invoice Review Determination",
      listener: :assign_user
    )
  end
end
