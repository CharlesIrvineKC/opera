defmodule OperaWeb.OperaComponents do
  use Phoenix.Component

  def input_field(assigns) do
    ~H"""
    <div>
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
    ~H"""
    <div class="mt-2">
      <label for="output" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
        <%= @name %>
      </label>
      <input
        type="text"
        name={@name}
        id="output"
        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        value={@value}
      />
    </div>
    """
  end
end
