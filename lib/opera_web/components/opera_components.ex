defmodule OperaWeb.OperaComponents do
  use Phoenix.Component

  alias Mozart.ProcessService, as: PS

  def is_html_safe (value) do
    case Phoenix.HTML.Safe.impl_for(value) do
      nil -> false
      _ -> true
    end
  end

  def input_field(assigns) do
    ~H"""
    <div :if={@value && is_html_safe(@value) } class="min-w-60">
      <label for="input" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
        <%= @name %>
      </label>
      <input
        type="text"
        id="input"
        class="bg-gray-100 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        value={@value}
        disabled
      />
    </div>
    """
  end

  def output_field(assigns) do
    type = PS.get_type(assigns.name)
    assigns = Map.put(assigns, :type, type)
    ~H"""
    <div>
      <label for="output" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
        <%= @name %>
      </label>
      <.string_output_field :if={!@type} name={@name} enabled={@enabled} value={@value} />
      <.radio_output_field
        :if={@type && @type.type == :choice}
        enabled={@enabled}
        choices={@type.choices}
        name={@name}
      />
      <.integer_output_field
        :if={@type && @type.type == :number}
        enabled={@enabled}
        name={@name}
        value={@value}
      />
    </div>
    """
  end

  def radio_output_field(assigns) do
    ~H"""
    <div>
      <div :for={choice <- @choices} class="flex items-center mb-4">
        <input
          id="default-radio-1"
          type="radio"
          value={choice}
          name={@name}
          required
          disabled={!@enabled}
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="default-radio-1" class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          <%= choice %>
        </label>
      </div>
    </div>
    """
  end

  def string_output_field(assigns) do
    ~H"""
    <input
      type="text"
      name={@name}
      required
      disabled={!@enabled}
      id="output"
      class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
      value={@value}
    />
    """
  end

  def integer_output_field(assigns) do
    ~H"""
    <input
      type="number"
      name={@name}
      required
      disabled={!@enabled}
      id="output"
      class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
      value={@value}
    />
    """
  end
end
