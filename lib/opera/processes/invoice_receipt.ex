defmodule Opera.Processes.InvoiceReceipt do
  use Mozart.BpmProcess

  def_bpm_application("Process Invoice",
    main: "Invoice Receipt Process",
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

  defprocess "Invoice Receipt Process" do
    prototype_task("Assign Approver Group")
    user_task("Approve Invoice", groups: "Admin", outputs: "Invoice Approved?")

    case_task "Approve Invoice Result" do
      case_i :invoice_approved do
        subprocess_task("Perform Bank Transfer SubTask", model: "Perform Bank Transfer")
      end
      case_i :invoice_sent_to_review do
        subprocess_task("Perform Invoice Approval Negotiation Subprocess",
          model: "Perform Invoice Approval Negotiation"
        )
      end
    end
  end

  defprocess "Perform Bank Transfer" do
    prototype_task("Prepare Bank Transfer")
    prototype_task("Archive Invoice")
  end

  defprocess "Perform Invoice Approval Negotiation" do
    repeat_task "Invoice Approval Negotiation", condition: :negotiation_not_resolved do
      subprocess_task("Review Invoice Subprocess", model: "Review Invoice Process")
      conditional_task "Reapprove if not Rejected", condition: :invoice_not_rejected do
        user_task("Reapprove Invoice", groups: "Admin", outputs: "Invoice Approved?")
      end
    end

    conditional_task "Negotiation Result", condition: :invoice_approved do
      subprocess_task("Perform Bank Transfer SubTask", model: "Perform Bank Transfer")
    end
  end

  defprocess "Review Invoice Process" do
    user_task("Assign Reviewer", groups: "Admin", outputs: "Invoice Reviewer ID")
    user_task("Review Invoice", groups: "Admin", outputs: "Invoice Review Determination")
  end
end
