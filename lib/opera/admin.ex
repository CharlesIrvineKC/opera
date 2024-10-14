defmodule Opera.Admin do
  use GenServer

  alias Mozart.ProcessService, as: PS

  @doc false
  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc "Get all loaded BPM applications."
  def get_bpm_applications() do
    Keyword.values(PS.get_bpm_applications())
  end

  @doc "Get all groups defined in all of the loaded BPM applications."
  def get_all_groups() do
    bpm_applications = get_bpm_applications()

    Enum.map(bpm_applications, & &1.groups)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort(&(&1 < &2))
  end

  @doc "Get all groups that a user has memebership in."
  def get_user_groups(user_id) do
    GenServer.call(__MODULE__, {:get_user_groups, user_id})
  end

  @doc "Add a user to a group."
  def add_user_to_group(user_id, group) do
    GenServer.cast(__MODULE__, {:add_user_to_group, user_id, group})
  end

  @doc "Add a user to a group."
  def remove_user_from_group(user_id, group) do
    GenServer.cast(__MODULE__, {:remove_user_from_group, user_id, group})
  end

  def init(_init_arg) do
    env = Application.fetch_env(:mozart, :database_path)

    path =
      case env do
        :error -> "database"
        {:ok, value} -> value
      end

    {:ok, user_group_db} = CubDB.start_link(data_dir: path <> "/user_group_db")

    {:ok, %{user_group_db: user_group_db}}
  end

  def handle_call({:get_user_groups, user_id}, _from, state) do
    groups = CubDB.get(state.user_group_db, user_id) || []
    {:reply, groups, state}
  end

  def handle_cast({:add_user_to_group, user_id, group}, state) do
    groups = CubDB.get(state.user_group_db, user_id) || []

    groups = [group | groups] |> Enum.uniq()

    CubDB.put(state.user_group_db, user_id, groups)
    {:noreply, state}
  end

  def handle_cast({:remove_user_from_group, user_id, group}, state) do
    groups = CubDB.get(state.user_group_db, user_id) || []

    groups = List.delete(groups, group)

    CubDB.put(state.user_group_db, user_id, groups)
    {:noreply, state}
  end
end
