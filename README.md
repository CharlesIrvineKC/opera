# Opera

## Introduction

**Opera** is a **proof of concept** user interface application to be used with [Mozart - a BPM platform written using Elixir](https://github.com/CharlesIrvineKC/mozart). It is implemented using **Phoenix LiveView**. It's purpose is to provide a concrete example of a Business Process Management (BPM) application driven by Mozart. You should find it useful for the following:

* Help those new to BPM understand its purpose and how it works.
* Help you understand the capabilities and services of Mozart.
* Executing your Mozart busines process models.
* Provide a baseline application that could be extended to have production quality and functionality.
* As an example to guide you in the development of your own Mozart related GUIs.

### Current Functionality

* Provide Sample Business Process Models
* Load Mozart Business Process Models
* Execute Business Process Instances
* Filtering and Completing User Tasks
* Examine In-Flight and Completed Process Instance State
* Administer BPM Users.

### Installation and Starting the Application

```
$ git clone https://github.com/CharlesIrvineKC/opera
$ cd opera
$ mix setup
$ mix phx.server
```

### Sample Business Process Models

You will find example business process models in:

```
lib/opera/processes
```

For those familiar with BPMN2 (a graphical standard for constructing process models), each of the sample process models has a jpeg snapshot of a BPMN2 diagram in:

```
priv/bpmn2
```

Even if you aren't familiar with BPMN2, you are encouraged to look at these diagrams as they are intuitively easy to understand.

## Registering and Logging in

After the server comes up, navigate to:

```
http://localhost
```

You should see a very rudimentary welcome screen where you can register and login. Use any email address and password you would like to register. Email addresses aren't verified.

After you register and login, you can navigate to either of three views - the **processes view**, the **tasks view** or the **users** view. We'll talk about the process view first.

## The Processes View


After you have started Opera, the processes view will be available at:

```
http://localhost:4000/processes
```

You can also navigate to the processes view by clicking the **processes** link in the top left of the screen.

When in this view, all process instances, both active and completed, are visible. Click on any process to view the details of a process instance. However, you must load your business process models into the system before you can execute process instances. 

### Loading Process Models

The **Processes View** allows you to load Mozart BPM application modules. See [Mozat documentation](https://hexdocs.pm/mozart/api-reference.html) on how to create a Mozart process models.

Opera comes with several example Mozart process modules. See the **config.exs** file for an examples of configuring a Mozart process models to be available for loading:

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
Load BPM Application
```

You can use this menu command to load business process applications. After you load a process application, you will be able to start process instances from the **tasks** view.

After deploying the **HomeLoadApp** you may want to skip ahead to the **Task View** section to start and execution **HomeLoanApp** process instances.

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

### Start a BPM Process Instance

The **Tasks View** allows you to start Mozart process applications and complete user tasks.

To start a process instance, press the **Start BPM Application** button and select the application that you wish to run.

You will then be preented with an input form to provide the initial data required by the process model. The inputs presented will depend on what you have specified in your process model, with one exception.

Enter the requested data and then press the **Start Application** button.

### Viewing and Completing User Tasks

If the process model that you are executing contains user tasks, you will see mouse sensitive user task summaries. Click on these to view the automatically generated task input form and complete the task. You must press the **Claim** button before you complete a task by pressing the **Submit** button. You can examine the history of the business process associated with a user task by clicking the **History** button.

### Filtering User Taskws

You can filter the user tasks visible on the **Tasks View** in multiple ways:

* By business process model.
* By user group.
* Those tasks that are assigned to the current user.
* Those tasks assigned to groups that the current user belongs to.

## The Users View

The **users view** allows you to assign (and unassign) user groups to users.






