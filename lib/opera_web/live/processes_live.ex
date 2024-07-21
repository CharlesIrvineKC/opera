defmodule OperaWeb.ProcessesLive do
  use OperaWeb, :live_view

  def mount(_params, _session, socket) do
    bpm_modules = Application.fetch_env!(:opera, :process_apps)
    {:ok, assign(socket, :bpm_modules, bpm_modules)}
  end

  def render(assigns) do
    ~H"""
    <.nav bpm_modules={@bpm_modules} />
    """
  end

  def nav(assigns) do
    ~H"""
    <nav class="mb-5 border border-black bg-gray-50 dark:bg-gray-700">
      <div class="max-w-screen-xl px-4 py-3 mx-auto">
        <div class="flex items-center">
          <ul class="flex flex-row font-medium mt-0 space-x-8 rtl:space-x-reverse text-sm">
            <li>
              <button
                data-modal-target="load-application-modal"
                data-modal-toggle="load-application-modal"
                class="block text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
                type="button"
              >
                Load Application
              </button>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    <.choose_application bpm_modules={@bpm_modules} />
    """
  end

  def choose_application(assigns) do
    ~H"""
    <div
      id="load-application-modal"
      tabindex="-1"
      aria-hidden="true"
      class="hidden overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 justify-center items-center w-full md:inset-0 h-[calc(100%-1rem)] max-h-full"
    >
      <div class="relative p-4 w-full max-w-md max-h-full">
        <!-- Modal content -->
        <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
          <!-- Modal header -->
          <div class="flex items-center justify-between p-4 md:p-5 border-b rounded-t dark:border-gray-600">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              Load Application
            </h3>
            <button
              type="button"
              class="end-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white"
              data-modal-hide="load-application-modal"
            >
              <svg
                class="w-3 h-3"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 14 14"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                />
              </svg>
              <span class="sr-only">Close modal</span>
            </button>
          </div>
          <!-- Modal body -->
          <div class="p-4 md:p-5">
            <form phx-submit="load-application" class="max-w-sm mx-auto">
              <div>
                <label
                  for="application_name"
                  class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
                >
                  BPM Application Module Name
                </label>
                <select
                  id="application"
                  name="application"
                  class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                >
                  <option selected>Choose a BPM application</option>
                  <option :for={{name, module} <- @bpm_modules} value={module}>
                    <%= name %>
                  </option>
                </select>
              </div>
              <button
                data-modal-hide="load-application-modal"
                type="submit"
                class="mt-6 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
              >
                Load
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("load-application", %{"application" => module_name}, socket) do
    module = Module.concat(Elixir, String.to_atom(module_name))
    apply(module, :load, [])
    {:noreply, socket}
  end
end
