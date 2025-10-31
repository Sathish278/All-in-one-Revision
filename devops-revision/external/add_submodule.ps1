# PowerShell helper to add and initialize the external devops-exercises submodule
# Run from repository root (C:\Revison)

Write-Host "Adding submodule bregman-arie/devops-exercises into devops-revision/external/devops-exercises"

git submodule add https://github.com/bregman-arie/devops-exercises.git devops-revision/external/devops-exercises

Write-Host "Initializing submodule(s)"
git submodule update --init --recursive

Write-Host "Done. To update the submodule in future run:`n git submodule foreach --recursive 'git fetch origin && git checkout master && git pull origin master'` (or replace master with main)"
