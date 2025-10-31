# Git - Consolidated Revision

Quick Git reference: branches, common commands, undo workflows and best practices.

## Common Commands
- init, clone, add, commit, push, pull, fetch, status, log
- branch creation: git checkout -b feature/x
- merge: git merge feature/x
- rebase: git rebase main (use with care)
- stash: git stash; git stash pop

## Undoing Changes
- git checkout -- <file>
- git reset --soft HEAD~1
- git reset --hard <commit>
- git reflog for recovery

## Best Practices
- Use feature branches and PRs
- Keep commit messages clear
- Use CI checks on PRs

## References
- ../../Devops/Git.md
