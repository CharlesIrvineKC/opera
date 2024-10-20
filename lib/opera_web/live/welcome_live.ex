defmodule OperaWeb.WelcomeLive do
  use OperaWeb, :live_view

  alias Opera.Accounts

  def mount(_parameters, session, socket) do
    user_token = Map.get(session, "user_token")
    user = if user_token, do: Accounts.get_user_by_session_token(user_token)
    {:ok, assign(socket, page_title: "Welcome to Opera", user: user)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-16">
      <h1 class="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
        Welcome to Opera
      </h1>
      <p class="mb-6 text-lg font-normal text-gray-500 lg:text-xl dark:text-gray-400">
        <b>Opera</b>
        is an proof-of-concept application for use with <b>Mozart - an Elixir based Business Process Management platform</b>.
      </p>
      <div class="flex flex-wrap">
      </div>
      <div class="flex flex-col gap-4">
        <div :if={!@user}>
          <a
            href="#"
            class="block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
          >
            <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
            Login Credentials
            </h5>
          <p class="font-normal text-gray-700 dark:text-gray-400">
            Feel free to login with user ID: <b>admin@opera.com</b>
            and password: <b>admin</b>. Or, you can register with your own user id (email address) and password. Opera doesn't do any kind of credentials verification, so you can specify made up credentials if you wish.
          </p>
          </a>
        </div>
        <div>
          <a
            href="#"
            class="block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
          >
            <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
              Tasks View
            </h5>
            <p class="font-normal text-gray-700 dark:text-gray-400">
              When logged in, a <b>Tasks</b>
              link should be visible at the right top of your browser window. Click on this link to expose the <b>Opera Task View</b>.
              <br /><br />
              <p><b>From this window, you can:</b></p>
              <ul class="space-y-1 text-gray-500 list-disc list-inside dark:text-gray-400">
                <li>Start Business Processes</li>
                <li>Claim a User Task</li>
                <li>Release (Unclaim) a User Task</li>
                <li>View a Task's Process History</li>
                <li>Complete a User Task <em>(You must claim it first.)</em></li>
              </ul>
            </p>
          </a>
        </div>
        <div>
          <a
            href="#"
            class="block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
          >
            <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
              Processes View
            </h5>
            <p class="font-normal text-gray-700 dark:text-gray-400">
              When logged in, a <b>Processes</b>
              link should be visible at the right top of your browser window. Click on this link to expose the <b>Opera Processes View</b>.
              <br /><br />
              <p><b>From this window, you can:</b></p>
              <ul class="space-y-1 text-gray-500 list-disc list-inside dark:text-gray-400">
                <li>Load Process Applications <em>(So you can start process instances.)</em></li>
                <li>View Active Processes</li>
                <li>View Completed Processes</li>
                <li>View Process Details <em>(by Clicking on a Process)</em></li>
              </ul>
            </p>
          </a>
        </div>
        <div class="mb-12">
          <a
            href="#"
            class="block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
          >
            <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
              Users View
            </h5>
            <p class="font-normal text-gray-700 dark:text-gray-400">
              When logged in, a <b>Users</b>
              link should be visible at the right top of your browser window. Click on this link to expose the <b>Opera Users View</b>.
              <br /><br />
              <p><b>From this view, you can:</b></p>
              <ul class="space-y-1 text-gray-500 list-disc list-inside dark:text-gray-400">
                <li>Assign / Delete Groups to / from Your User ID</li>
                <li>Delete Users from Opera<em> (but just your own ID, please</em></li>
              </ul>
            </p>
          </a>
        </div>
      </div>
    </div>
    """
  end
end
