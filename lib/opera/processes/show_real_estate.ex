defmodule Opera.Processes.ShowRealEstate do
  use Mozart.BpmProcess

  def_bpm_application("Real Estate Showing",
    data: "Customer Name,Phone Number",
    bk_prefix: "Customer Name,Phone Number"
  )

  def_bpm_application("Send Showing Contact Info",
    data: "Customer Name,Phone Number",
    bk_prefix: "Customer Name,Phone Number"
  )

  def need_contact_info(data) do
    data["Need More Info"] == "Yes"
  end

  def necessary_info_provided(data) do
    data["Need More Info"] == "No"
  end

  def_choice_type("Need More Info", choices: "Yes,No")

  def receive_contact_info(message, state_data) do
    case message do
      %{"Customer Name" => name, "Phone Number" => phone_number} ->
        if name == state_data["Customer Name"] do
          %{"Phone Number" => phone_number}
        end

      _ ->
        nil
    end
  end

  defprocess "Real Estate Showing" do
    user_task("Receive Showing Request", group: "Sales", outputs: "Need More Info")

    case_task "Handle Showing Request" do
      case_i :need_contact_info do
        user_task("Send Contact Info Request", group: "Sales", outputs: "Information Needed")
        receive_task("Wait for Contact Info", selector: :receive_contact_info)
        subprocess_task("Info Received - Do Showing", process: "Schedule Showing")
      end

      case_i :necessary_info_provided do
        subprocess_task("Info Sufficient - Do Showing", process: "Schedule Showing")
      end
    end
  end

  defprocess "Schedule Showing" do
    prototype_task("Schedule Showing")
  end

  def build_message(data) do
    %{"Customer Name" => data["Customer Name"], "Phone Number" => data["Phone Number"]}
  end

  defprocess "Send Showing Contact Info" do
    send_task("Send Contact Info", generator: :build_message)
  end
end
