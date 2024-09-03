defmodule OperaWeb.FormHelper do
  @input_field_ordering %{
    Opera.Processes.HomeLoanApp => [
      "First Name",
      "Last Name",
      "Debt",
      "Income"
    ],
    Opera.Processes.InvoiceReceipt => [
      "First Name",
      "Last Name"
    ]
  }

  def get_ordered_inputs(module, data) do
    ordering = @input_field_ordering[module]

    if ordering do
      ordered_inputs =
        Enum.reduce(ordering, [], fn field, acc ->
          value = Map.get(data, field)
          if value, do: acc ++ [{field, value}], else: acc
        end)

      data =
        Enum.reduce(data, [], fn {k, v}, acc ->
          if Enum.find(ordered_inputs, fn {k1, _v1} -> k == k1 end) do
            acc
          else
            [{k, v} | acc]
          end
        end)

      ordered_inputs ++ data
    else
      data
    end
  end
end
