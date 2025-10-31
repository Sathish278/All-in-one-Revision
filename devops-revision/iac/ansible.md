# Ansible - Consolidated Revision

This file consolidates Ansible content and provides quick playbook examples and commands for review.

## Core Concepts
- Agentless (SSH/WinRM), YAML playbooks, idempotency
- Inventory (INI or YAML), group_vars, host_vars
- Modules (apt, yum, copy, template, service, user, file, etc.)
- Roles and Collections (ansible-galaxy)
- Handlers, facts, templates (Jinja2)

## Quick Examples
- Simple playbook:
```yaml
- name: Install and start nginx
  hosts: web
  become: yes
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: true
```

## Useful Commands
- Run ad-hoc ping: ansible all -m ping
- Run playbook: ansible-playbook -i inventory site.yml
- Syntax check: ansible-playbook site.yml --syntax-check
- Check mode (dry-run): ansible-playbook site.yml --check
- View config: ansible-config view
- Lint: ansible-lint playbook.yml

## Variable precedence (high→low):
- extra vars, set_facts, include_vars, role vars, play vars, host facts, host vars, group vars, role defaults

## Best Practices
- Use roles for modularity
- Keep secrets in Vault/Secrets Manager and reference via lookup
- Use `become:` for privilege escalation rather than direct root

## References
- ../../ansible-learn/ansible.md
- ../../Devops/Ansible.md
- ../../Interviews-questions/Ansible.md
