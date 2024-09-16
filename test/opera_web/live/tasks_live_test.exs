defmodule OperaWeb.Live.TasksLiveTest do
  use ExUnit.Case

  alias OperaWeb.TasksLive, as: TL

  test "generate business key " do
    data = %{
      "Debt" => "0",
      "First Name" => "John",
      "Income" => "100",
      "Last Name" => "Doe"
    }
  bk_prefix = ["Last Name", "First Name", "Income"]

  assert TL.generate_bk_prefix(data, bk_prefix) == "Doe-John-100"
  end
end
