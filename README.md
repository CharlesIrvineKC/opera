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
$ mix setup
$ mix phx.server
```

## Registering and Logging in

After the server comes up, navigate to:

```
http://localhost
```

You should see a very rudimentary welcome screen. Register and login. Use any email address and password you would like. Email addresses aren't verified.

After you register and login, you can navigate to either of two views - the **processes view** or the **tasks view**. We'll talk about the process view first.

## The Processes View


After you have started Opera, the processes view will be available at:

```
http://localhost:4000/processes
```

You can also navigate to the processes view by clicking the **processes** link in the top left of the screen.

### Loading Process Models

The **Processes View** allows you to load Mozart BPM application modules. See [Mozat documentation](https://hexdocs.pm/mozart/api-reference.html) on how to create a Mozart process models.

Opera comes with several Mozart process modules. See **config.exs** for an examples of configuring a Mozart process models to be available for loading:

```
  config :opera, :process_apps, [
    {"Process a Home Loan", Opera.Processes.HomeLoanApp},
    {"Prepare Bill", Opera.Processes.PrepareBillApp},
    {"Payment Approval", Opera.Processes.PaymentApprovalApp},
    {"Process Invoice", Opera.Processes.InvoiceReceipt}
  ]
```

After you've made this configuration setting, process apps are available for loading using the menu item:

```
Applications >> Deploy an Application
```

You can use this menu command to load the built in business process applications or one of your own. After you load a process application, you will be able to start process instances from the **tasks** view.

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

You can also navigage to this view by clicking on the **tasks** link in the top right of your screen.

The **Tasks View** allows you to start Mozart process applications and complete user tasks.

To start a process instance, press the **Start BPM Application** button and select the application that you wish to run.

You will then be preented with an input form to provide the initial data required by the process model. The inputs presented will depend on what you have specified in your process model, with one exception.

Enter the requested data and then press the **Start Application** button.

If the process model that you are executing contains user tasks, you will see mouse sensitive user task summaries. Click on these to view the automatically generated task input form and complete the task. You must press the **Claim** button before you complete a task by pressing the **Submit** button.






