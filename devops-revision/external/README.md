# Add `bregman-arie/devops-exercises` as a submodule

Goal
- Add the well-known `devops-exercises` repository as a git submodule inside this workspace so you can reference its extensive topic/exercise content without copying it.

Why submodule
- Keeps the original repository intact and attributed.
- Avoids copying large amounts of content and respects licensing/no-derivatives restrictions.
- Easy to update from upstream with `git submodule update --remote`.

How to add the submodule (PowerShell)

Run these commands from the repository root (`C:\Revison`):

```powershell
# add the submodule into devops-revision/external/devops-exercises
git submodule add https://github.com/bregman-arie/devops-exercises.git devops-revision/external/devops-exercises
git submodule update --init --recursive

# later, to update the submodule to the latest upstream commit
git submodule foreach --recursive 'git fetch origin && git checkout master && git pull origin master'
```

If your Git default branch is `main` replace `master` with `main` in the update command.

Notes on license
- The upstream repository uses CC BY-NC-ND 3.0 (No Derivatives, Non-Commercial). Using it as a submodule to reference and read is fine; if you want to copy and modify content into this repo you must respect the licence and keep attribution. If you need derivative or commercial use, obtain permission or recreate content in your own words.

Mapping & next steps
- Use `TOPICS.md` (in this folder) for a suggested mapping of upstream topics to local `devops-revision/` files.
- After adding the submodule you can:
  - Leave the content in the submodule and create local pointers (short READMEs that reference submodule files), or
  - Copy selected topic files into `devops-revision/` (do this only when you confirm license compliance).

If you'd like, I can create the pointer READMEs automatically after you add the submodule (or I can create them now and you can update paths once the submodule exists).
