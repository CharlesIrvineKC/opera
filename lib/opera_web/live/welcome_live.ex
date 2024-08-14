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
      <a
        :if={!@user}
        href="#"
        class="mb-5 mr-5 block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
      >
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          Login Credentials
        </h5>
        <p class="font-normal text-gray-700 dark:text-gray-400">
          For now, login with user ID: <b>admin@opera.com</b> and password: <b>admin</b>. Soon, we will have addition testing credentials established to exercise different Opera/Mozart functionalities.
        </p>
      </a>
    </div>
    <%!-- <button
      phx-click="list-subjects"
      type="button"
      class="mb-20 text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-green-600 dark:hover:bg-green-700 focus:outline-none dark:focus:ring-green-800"
    >
      Explore Subjects
    </button> --%>
    </div>
    """
  end
end
