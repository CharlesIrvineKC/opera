defmodule OperaWeb.TestLive do
  use OperaWeb, :live_view

  def mount(_params, _session, socket) do
    names = ["one", "two", "three"]
    selected_name = nil
    show_modal = false
    {:ok, assign(socket, names: names, selected_name: selected_name, show_modal: show_modal)}
  end

  def render(assigns) do
    ~H"""
    <form class="max-w-sm mx-auto">
      <div class="flex items-center mb-4">
        <input
          id="default-radio-1"
          type="radio"
          value=""
          name="default-radio"
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="default-radio-1" class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Default radio
        </label>
      </div>
      <div class="flex items-center">
        <input
          id="default-radio-2"
          type="radio"
          value=""
          name="default-radio"
          class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
        />
        <label for="default-radio-2" class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">
          Checked state
        </label>
      </div>
    </form>
    """
  end
end
