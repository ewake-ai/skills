---
name: ewake-report-deployments
description: Add the Ewake deployment report step to the CI pipeline of this repository and open a pull request. Use when the user wants Ewake to know about deployments, deployment tracking, or release watch. Use also when ewake-check-setup reports that the step is missing.
---

# Report deployments to Ewake

Ewake compares production problems with recent deployments. For this, the pipeline sends one HTTPS request to Ewake after each production deployment.

Full reference: `https://docs.ewake.ai/integrations/deployment/deployment-tracking.md`

## Rules

- Do not ask the user for the value of the API key. Do not write the key to a file, a commit, or the conversation.
- Do not change the deployment logic. Only add the report step, or correct an existing report step.
- The report step must run after the deployment succeeds.
- The report step must not cause the deployment to fail.
- Add the report step to production deployments only.
- Show the full change to the user before you commit. Open the pull request only after the user agrees.

## Steps

### 1. Find the production deployment

1. Search for the pipeline definition. Look at `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/config.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`, `azure-pipelines.yml`, and the deployment scripts.
2. Find the job that deploys to production. If you find no such job, or more than one, ask the user.
3. Search the pipeline for `ewake-ai/report-deployment-action`, `/api/v1/events/deployment`, and `ewake-report-deployment.sh`. If the pipeline already reports to Ewake, keep the report where it is, with all its inputs and secrets. Make sure that it agrees with these rules:
   - The report runs after the deployment. It is later in the same job, or in a separate job that starts only after the production deployment job ends.
   - GitHub Actions: the report step, or its separate job, has `continue-on-error: true`.
   - Other CI systems: the report command ends with `|| true`.

   If the report runs before the deployment step, move it after the deployment step, in the same job. Add a missing `continue-on-error: true` or `|| true`. Change nothing else. If you change an item, go to step 6.

   If you change nothing and a tool with a name that ends with `ewake_list_deployments` is available, do these steps:
   - Call the tool. Set `repository` to the owner and the name of the repository, for example `my-org/my-service`. Set `from` to the time 14 days ago and `to` to the time now.
   - If the tool gives a deployment, find the newest deployment. Tell the user its time, its artifact name, and its commit.
   - If the tool gives no deployment, tell the user that Ewake received no deployment in the last 14 days. Ask the user if the pipeline deployed to production in that time. If it did, read the troubleshooting section of the full reference. Then help the user.

   If you change nothing, tell the user. Then stop.
4. If the repository deploys more than one service, each service gets its own report step.

### 2. Get the artifact name

The artifact name must be the same as the service name in the observability tools of the user, for example Datadog or Grafana. If the names are different, Ewake accepts the event but cannot connect it to the service.

1. If a tool with a name that ends with `ewake_list_service_names` is available, call it with `search` set to the repository name. If the result is empty, call it again with no `search`.
2. Show the applicable names to the user. Ask the user to select one. Use the name exactly as the tool gives it.
3. If the tool is not available, or no name is applicable, ask the user for the service name from their observability tools.

### 3. Get the Ewake address

Ask the user if their company uses hosted Ewake or self-hosted Ewake.

- **Hosted.** The pipeline sends events to `https://api.ewake.ai`. This is the default.
- **Self-hosted.** The pipeline sends events to the address of the Ewake instance of the user. The address must start with `https://`. If the user gives an address without `https://`, add `https://` at the start. Remove a `/` at the end.

### 4. Tell the user to create the secret

Give these instructions to the user:

1. Open **API Keys** in the Ewake dashboard and create a key. The dashboard shows the key one time.
2. Put the key in the secret store of the CI system with the name `EWAKE_API_KEY`. On GitHub, use a repository secret, not an environment secret.

Continue with the next step. Do not wait for the secret.

### 5. Add the report step

**GitHub Actions.** For a new report, add a new job to the workflow that deploys to production. Do not add the report to the deployment job. An organization policy can stop a job before it starts if the policy does not allow an action. In a separate job, such a stop affects only the report.

```yaml
report-deployment:
  needs: <production deployment job>
  runs-on: <runs-on value of the production deployment job>
  continue-on-error: true
  steps:
    - name: Report deployment to Ewake
      uses: ewake-ai/report-deployment-action@v1
      with:
        api-key: ${{ secrets.EWAKE_API_KEY }}
        artifact-name: "<artifact name>"
```

- Keep `needs` and `continue-on-error: true`. The job starts only after the deployment succeeds. If the job fails, the workflow does not fail.
- If the other `uses:` lines in the repository use a full commit SHA, do the same here. Get the SHA with `git ls-remote https://github.com/ewake-ai/report-deployment-action 'refs/tags/v1^{}'`. Write `ewake-ai/report-deployment-action@<SHA> # v1`.
- For self-hosted Ewake, add `api-url: "<Ewake address>"` to the `with` block.

**All other CI systems.**

1. Copy the file `report-deployment.sh` from the folder of this skill to `scripts/ewake-report-deployment.sh` in the repository. Do not change the file. It always exits with code 0.
2. Add this command as the last command of the production deployment job:

   ```sh
   sh scripts/ewake-report-deployment.sh || true
   ```

3. Give these environment variables to that command:

   | Variable | Value |
   |---|---|
   | `EWAKE_API_KEY` | The secret `EWAKE_API_KEY` |
   | `EWAKE_ARTIFACT_NAME` | The artifact name from step 2 |
   | `EWAKE_REPOSITORY` | The repository as `owner/name` |
   | `EWAKE_REPOSITORY_URL` | The full repository URL, for example `https://github.com/my-org/my-service` |
   | `EWAKE_COMMIT_SHA` | The commit variable of the CI system. If you do not set it, the script uses `git rev-parse HEAD`. |
   | `EWAKE_API_URL` | Self-hosted Ewake only: the Ewake address |

   Use the variables that the CI system supplies for the commit and the repository, if they exist.

### 6. Open the pull request

1. Show the full change to the user.
2. After the user agrees, create a branch, commit the change, and open a pull request.
3. Write these items in the description of the pull request:
   - The change reports each production deployment to Ewake.
   - The report cannot cause the deployment to fail.
   - The CI secret `EWAKE_API_KEY` is necessary before the first deployment.
   - GitHub only: if the organization allows only some actions, an administrator must allow `ewake-ai/report-deployment-action`.

### 7. Tell the user how to make sure that it works

After the next production deployment, the deployment shows on the **Releases** page of the Ewake dashboard.

If it does not show, read the troubleshooting section of the full reference. Then help the user.

If a tool with a name that ends with `ewake_list_deployments` is available, the user can also run the skill `ewake-check-setup` after the deployment. It checks that Ewake received the deployment.
