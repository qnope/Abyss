# Execute Project Skill

## Skill: Execute All Tasks in Directory with Subagent

In `specs/projects/$1/tasks/`, for each task file, spawn a subagent to execute the task. Collect and report the results from all subagents.
You can check the `specs/projects/$1/tasks/Dependency.md` for helping you to parallelize the work.

## Usage
`/execute-project <project_name>`

## Steps
1. For each task file in `specs/projects/$1/tasks/` (excluding Dependency.md), spawn a subagent with the corresponding task file as input. Can be parallelized if there is no dependency between tasks (see `specs/projects/$1/tasks/Dependency.md`).
2. When all tasks are completed, check that all tests are passing and that the implementation is correct. If not, continue to work on them.
3. When all tasks are completed and all tests are passing, report the results of all tasks in a clear and concise manner. Include any relevant information such as the time taken for each task, any challenges faced, and how they were overcome. Write to the user that if everything is correct, he can launch "/finalize-project <project_name>" to finalize the project.

## Working on a task
1. Subagent may check the `specs/architecture/` for helping it to execute the task.
2. The subagent will execute the implementation steps, run the tests, and check that the implementation is correct. If not, it will continue to work on the task until it is done.
3. A task is considered done when all implementation steps are completed, all tests are passing, and the implementation is correct. 
4. When task is finished, commit.

## commit message format

```markdown
<project_name><task_number> Quick description of the task

Summary of the implementation and any relevant information
```
