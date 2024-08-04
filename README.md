# Opera

## Introduction

**Opera** is a **proof of concept** user interface application to be used with [Mozart - a BPM platform written using Elixir](https://github.com/CharlesIrvineKC/mozart). It is early in development and is far from suitable for procduction use. However, you may find it useful for the following:

* Executing your Mozart busines process models.
* As an example to guide you in the development of your own Mozart related GUIs.

### Current Functionality

* Load a Morart BPM Application Module
* Execute Process Instances
* Completing User Tasks
* Examine Process Instance State

### Installation and Starting the Application

```
$ git clone https://github.com/CharlesIrvineKC/opera
$ cd opera
$ mix deps.get
$ mix phx.server
```

## The Processes View


After you have started Opera, the processes view will be available at:

```
http://localhost:4000/processes
```

### Loading Process Models

The **Processes View** allows you to load Mozart BPM application modules. See [Mozat documentation](https://hexdocs.pm/mozart/api-reference.html) on how to create a Mozart process models.

Opera comes with an example Mozart process module - **Opera.Processes.HomeLoanApp**. See **config.exs** for an example of configuring a Mozart process model to be available for loading. Search for the following in the config.exs file:

```
config :opera, :process_apps, [
    {"Process a Home Loan", Opera.Processes.HomeLoanApp}
  ]
```

After you've made this configuration setting, process apps are available for loading using the menu item:

```
Applications >> Deploy an Application
```

You can use this menu command to load the **HomeLoanApp**. You will need to do this to start executing instances of the Mozart process module.

After deploying the **HomeLoadApp** you may want to skip ahead to the **Task View** section to start and execution **HomeLoanApp** process instances.

### Examining Active and Completed Processes

After you have experimented with executing process models, use the following menu commands to examine your process instances:

```
Processes >> Active Processes
Processes >> Completed Processes
```

### Clearing All Process State

If you want to reinitialize all Mozart data, execute the menu command:

```
Admin >> Clear Databases
```

You would never do this in a production setting, but the command is useful in the context of experimentaion.

## The Tasks View

The **Tasks View** is available at:

```
http://localhost:4000/tasks
```

The **Tasks View** allows you to start Mozart process applications and complete user tasks.

To start a process instance, press the **Start BPM Application** button and select the application that you wish to run.

You will then be preented with an input form to provide the initial data required by the process model. The inputs presented will depend on what you have specified in your process model, with one exception.

All process model invocations allow you to specify a **business key prefix**. Mozart will append a data/time stamp to the prefix to create a unique key to tie the top level process instance with all of its subprocesses. If you don't specify a prefix, Mozart will use a default prefix.

Enter the requested data and then press the **Start Application** button.

If the process model that you are executing contains user tasks, you will see mouse sensitive user task summaries. Click on these to view the automatically task input form and complete the task.






