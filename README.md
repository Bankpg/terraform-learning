# slipplus-git-ops

Terraform for the slipplus production Droplet on DigitalOcean. Same layout and run trigger as `petio-git-ops`: HCP Terraform watches this repo through its VCS connection and runs plan and apply, so there is no GitHub Actions workflow.

```
envs/prod/         root module for prod -> HCP workspace slipplus-prod
modules/droplet/   Droplet (imported, not created)
```

Scope: Terraform manages the existing prod Droplet only. The firewall is not managed here. The app deploy (image pull and `docker compose`) stays in `slipplus-web`'s `deploy-dev.yml`.

There is no dev environment yet. Add `envs/dev` when a second Droplet exists.

## One-time HCP Terraform setup

1. Create workspace `slipplus-prod` in org `bindzertech`, execution mode Remote.
2. In the workspace:
   - **Version control:** connect this repo.
   - **Terraform working directory:** `envs/prod`.
   - **Trigger patterns:** `envs/prod/**` and `modules/droplet/**`. Otherwise a change to the module will not start a run.
   - **Apply method:** manual, so someone approves each apply in HCP.
3. **Environment variable** `DIGITALOCEAN_TOKEN` (sensitive).
4. **Terraform variables** (non-sensitive), none with a default:
   - `droplet_id`: ID of the existing Droplet
   - `name`, `region`, `size`: must match the existing Droplet
   - `image`: any valid slug (not applied to the imported Droplet)

## First apply (import)

- Read the plan before applying. It should show one import and no add, change or destroy. If `name`, `region` or `size` differ from the real Droplet, the plan will show a change to them. Fix the variables instead of applying.
- `prevent_destroy` is set on the Droplet, so a plan that would destroy it fails.
- After the first successful apply, delete the `import` block from `envs/prod/main.tf`.

## Notes

- `image` only matters when creating a Droplet. Changing it in config does nothing to this server.
- Every tag pushed to `slipplus-web` deploys to `DROPLET_HOST`. While this is the only Droplet, that means production.
