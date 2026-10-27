# slipplus-git-ops

Terraform for the slipplus prod Droplet on DigitalOcean. Same layout and run flow as `petio-git-ops`: HCP Terraform watches this repo through its VCS connection and runs plan and apply. There are no GitHub Actions workflows.

```
envs/prod/          root module for prod -> HCP workspace slipplus-prod
  terraform.tf      backend and providers
  variables.tf
  imports.tf        one-time import of the existing Droplet (delete after the first apply)
  main.tf           Droplet module call
  outputs.tf
modules/droplet/    Droplet
```

## Flow

- **Pull request:** HCP runs a speculative plan. Nothing is applied.
- **Merge to `main`:** HCP runs a plan. Apply waits for manual approval in HCP.
- **Deploy:** not part of this repo. `slipplus-web`'s `deploy-dev.yml` deploys on tag push.

## HCP Terraform setup

- Workspace `slipplus-prod` in org `bindzertech`, execution mode Remote.
- Version control: connect this repo. Terraform working directory `envs/prod`. Trigger patterns `envs/prod/**` and `modules/droplet/**`.
- Apply method: manual.
- Environment variable `DIGITALOCEAN_TOKEN` (sensitive).
- Terraform variables (non-sensitive, no defaults): `droplet_id`, `name`, `region`, `size`, `image`.

## First run

1. Run the plan. It should show one import and no add, change or destroy. If `name`, `region` or `size` differ from the real Droplet, fix the variables instead of applying.
2. Apply.
3. Delete `envs/prod/imports.tf` and merge the change.

## Notes

- The Droplet has `prevent_destroy`. Remove it only when you intend to replace the server.
- `image` and `ssh_keys` are only used at creation. Changing them in config does nothing to the live server.
- Pushing a tag to `slipplus-web` deploys to `DROPLET_HOST`. While this is the only Droplet, that means production.
- There is no `envs/dev` because there is no second Droplet yet.
