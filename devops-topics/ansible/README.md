```markdown
# Ansible — interview-ready revision

> Summary: Ansible playbooks, roles, inventories, idempotence, and common patterns for configuration management and orchestration.
>
> How to use: practice writing small playbooks, create reusable roles, and validate with `ansible-lint` and `molecule` tests.

1) Concepts
- Playbooks, tasks, handlers, roles, inventories, variables, and vault for secrets.

2) Quick example (playbook)
```yaml
- hosts: web
  become: true
  roles:
    - nginx
```

3) Roles & testing
- Structure roles with `tasks/`, `handlers/`, `defaults/`; use Molecule for role testing.

4) Idempotence
- Ensure tasks are idempotent by using `creates`, `when`, and proper module usage (avoid raw shell where possible).

5) Interview Q&A
- Q: How to handle secrets? A: Use Ansible Vault or integrate with external secret management (Vault, AWS Secrets Manager) in CI.

--

I can add a role skeleton and a Molecule test example if you'd like.
```
