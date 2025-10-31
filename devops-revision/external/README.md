# devops-exercises (external submodule) — usage & guidance

This folder documents how we include the third-party `bregman-arie/devops-exercises` repository as an external submodule and how to use it safely from the revision hub.

Why we keep it as a submodule
--------------------------------
- Preserves original authorship and license terms.
- Avoids copying large exercise content into this repository (keeps repo size smaller).
- Lets you update upstream content independently with git submodule commands.

Current location
----------------
The submodule is added at the top-level path `devops-exercises/`.

How to update the submodule
---------------------------
From the repository root run:

```powershell
# fetch the latest upstream branch and update the submodule working tree
git submodule update --init --remote devops-exercises
```

If you prefer to fetch and checkout a specific branch inside the submodule:

```powershell
cd devops-exercises
git fetch origin
git checkout main   # or master if upstream uses master
git pull origin main
cd ..
git add devops-exercises
git commit -m "Update devops-exercises submodule"
```

License / attribution notes
---------------------------
- Upstream license: CC BY-NC-ND 3.0 (No Derivatives, Non-Commercial). This means you may read and reference the content, but you should not copy and re-publish modified versions of it.
- To avoid license conflicts we: (a) keep the full exercise corpus as a submodule, and (b) write original, interview-focused READMEs under `devops-topics/` rather than copying material verbatim.

How to use from the revision hub
--------------------------------
1. Read concise, interview-focused topics in `devops-topics/`.
2. When you want exercises or worked solutions, open the link from `devops-revision/external/INDEX.md` which points into `devops-exercises/`.

If you'd like, I can add a short checklist and a CI step to verify the submodule is initialized when cloning this repository.
