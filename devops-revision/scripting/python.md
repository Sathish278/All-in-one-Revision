# Python for DevOps - Consolidated Revision

This consolidates Python content focused for DevOps automation and quick examples.

## Core Topics
- Data types, file I/O, string handling, lists, dicts, sets
- Using subprocess, boto3 (AWS SDK), paramiko for SSH automation
- Packaging scripts, virtualenv, pip, requirements.txt

## Quick Examples
- Read a file:
```python
with open('file.txt') as f:
    for line in f:
        print(line.strip())
```
- Run shell command:
```python
import subprocess
subprocess.run(['ls','-la'], check=True)
```
- Boto3 example (list S3 buckets):
```python
import boto3
s3 = boto3.client('s3')
for b in s3.list_buckets()['Buckets']:
    print(b['Name'])
```

## Best Practices
- Use virtualenv or venv, pin dependencies in requirements.txt
- Add logging and error handling for automation scripts
- Keep secrets out of repo; use env vars or secret managers

## References
- ../../Devops/Python.md
- ../../python-devops/README.md
