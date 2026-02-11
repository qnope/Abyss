# Finalize Project Skill

User now considers the project done. All the code available (commited or not) is the final version of the project. The goal of this skill is to finalize the project by writing a nice commit message, updating the documentation, and moving the project to the `done` directory.

## usage
`/finalize-project <project_name>`

## Steps
1. Update the documentation in`specs/architecture/`. Keep the files and directory well organized and simple. Try to stay below 100 lines per file. Don't document the implementation details, just the architecture and design decisions. You can also add diagrams if needed.
2. Move the project from `specs/projects/<project_name>/` to `specs/done/<project_name>/`. You can keep the same structure inside the project directory.
3. Create nice commit message well structured (take into account files that are not commited). You can take all the commits associated to the current project. Generally they will be in the format `<project_name>: <task_number> description`. If there are other commits, you can reorder them and change their message to make them more clear and professional.
4. Create a Pull Request (if it already exists, update it) with a clear description of the project, the main features, and any relevant information. You can also add screenshots or gifs if needed. Make sure to highlight the files that are really sensitive or important to review. You can also ask for specific feedback from the reviewers if needed.
