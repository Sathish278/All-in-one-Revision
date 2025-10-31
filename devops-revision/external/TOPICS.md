# devops-exercises -> local mapping

This file lists the major topic groups present in `bregman-arie/devops-exercises` and suggests where they should map in `devops-revision/`.

Workflow recommendation
- Step 1: add the external repo as a submodule using `add_submodule.ps1` or the commands in `README.md`.
- Step 2: decide which topics you want duplicated (copied) into `devops-revision/` as standalone, interview-ready READMEs (we already created many). For topics you don't copy, keep references to the submodule.

Suggested mapping (topics you likely want at top-level in `devops-revision`):

- linux -> `devops-revision/linux/linux.md` (already present)
- kubernetes -> `devops-revision/containers/kubernetes.md` (already present)
- docker/containers -> `devops-revision/containers/docker.md`
- prometheus -> `devops-revision/monitoring/prometheus.md` (already present)
- grafana -> `devops-revision/monitoring/grafana.md` (already present)
- opentelemetry -> `devops-revision/observability/opentelemetry.md` (already present)
- aws -> `devops-revision/cloud/aws.md` (already present)
- azure/gcp -> `devops-revision/cloud/` (create azure.md, gcp.md if needed)
- terraform -> `devops-revision/iac/terraform.md` (already present)
- ansible/puppet -> `devops-revision/iac/ansible.md` (already present)
- git -> `devops-revision/git/git.md` (already present)
- python/go/sql -> `devops-revision/scripting/python.md` (we can add go/sql under scripting or a separate `coding/` folder)
- openstack -> `devops-revision/cloud/openstack.md` (optional)
- elastic/elasticstack/logging -> `devops-revision/monitoring/logging.md` or `devops-revision/observability/elastic.md`
- networking -> `devops-revision/networking/networking.md` (already present)

Large lists in the external repo (exercises/topics) can remain in the submodule and you can reference exact files by path. If you want me to copy specific topic folders into `devops-revision/` as full, interview-ready README files, list them and I'll convert them one-by-one (respecting license requirements).
