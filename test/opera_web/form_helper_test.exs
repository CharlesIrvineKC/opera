defmodule OperaWeb.FormHelperTest do
  use ExUnit.Case

  alias OperaWeb.FormHelper

  test "order data inputs" do
    data = %{"First Name" => "Charles", "Last Name" => "Irvine", "Debt" => 0, "Income" => 0}
    ordered_data = FormHelper.get_ordered_inputs(Opera.Processes.HomeLoanApp, data)

    assert ordered_data == [
             {"First Name", "Charles"},
             {"Last Name", "Irvine"},
             {"Debt", 0},
             {"Income", 0}
           ]
  end

  test "more data than fields" do
    data = %{
      "First Name" => "Charles",
      "Foobar" => 0,
      "Last Name" => "Irvine",
      "Debt" => 0,
      "Income" => 0
    }

    ordered_data = FormHelper.get_ordered_inputs(Opera.Processes.HomeLoanApp, data)

    assert ordered_data == [
             {"First Name", "Charles"},
             {"Last Name", "Irvine"},
             {"Debt", 0},
             {"Income", 0},
             {"Foobar", 0}
           ]
  end
end
