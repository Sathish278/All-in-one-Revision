```markdown
# Git — interview-ready revision

> Summary: Git fundamentals and advanced workflows for teams — branching strategies, rebasing vs merging, submodules, and large-repo management.
>
> How to use: practice workflows (feature branches, PRs, release branches), learn to recover with reflog, and use hooks/CI for checks.

1) Core commands
- Clone, commit, branch, merge, rebase, cherry-pick, reset, reflog.

2) Recommended workflows
- Trunk-based vs Git-flow: prefer trunk-based for continuous delivery, use short-lived feature branches and CI gatekeeping.

3) Submodules & subtrees
- Submodules for linking external repos (be explicit about versions). Subtrees for simpler vendorized copies.

4) Large repositories
- Use sparse-checkout, partial clones, and git-lfs for large binary files.

5) Interview Q&A
- Q: Merge vs rebase? A: Rebase for linear history and cleaner bisecting; merge preserves true history. Use carefully on shared branches.

--

I can add a quick recovery cheat-sheet (commonly needed `git` rescue commands) and sample branch-protection rules for GitHub/GitLab.
```
