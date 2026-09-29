---
name: ewake-check-setup
description: Check what Ewake knows about this repository and report what is missing. Use when the user asks if the Ewake setup is correct, asks what Ewake knows about this repository, or asks for the next step. This skill changes nothing.
---

# Check the Ewake setup

This skill is read-only. It makes a report. It does not change a file, open a pull request, or change Ewake.

A tool name can have a prefix, for example `mcp__ewake__ewake_run_cypher_query`.

## Steps

### 1. Check the connection

Check if a tool with a name that ends with `ewake_run_cypher_query` is available. If it is not available, do not do step 2.

### 2. Check what Ewake knows

1. Get the repository name from the command `git remote get-url origin`.
2. Call `ewake_load_cypher_skill` one time. It gives the graph schema and example queries.
3. Use `ewake_run_cypher_query` to answer these questions:
   - Is this repository in Ewake?
   - Which services have this repository as their source?
   - Which services do these services call, and which services call them?

Write each query from the schema that the tool gives. Do not guess the name of a label or of a relationship.

### 3. Check the repository

1. Search the pipeline definition for `ewake-ai/report-deployment-action`, `/api/v1/events/deployment`, and `ewake-report-deployment.sh`.
2. Make sure that the report agrees with these rules:
   - The report runs after the deployment. It is later in the same job, or in a separate job that starts only after the production deployment job ends.
   - GitHub Actions: the report step, or its separate job, has `continue-on-error: true`.
   - Other CI systems: the report command ends with `|| true`.

### 4. Report

Show one table with these four rows:

| Check | Result | Details or next step |
|---|---|---|
| Ewake tools | | |
| Repository in Ewake | | |
| Service linked to this repository | | |
| Deployment report step | | |

Use only these results: **OK**, **Missing**, **Not checked**.

- If the Ewake tools are not available, the second and third rows are **Not checked**.
- For an **OK** result, write what Ewake knows in the last column. For example, the service names and the services that they call.
- For a **Missing** result, write the next step from this table:

| Missing item | Next step |
|---|---|
| Ewake tools | Run the skill `ewake-connect`. |
| Repository in Ewake | Connect GitHub or GitLab in the Ewake dashboard. |
| Service linked to this repository | Run the skill `ewake-report-deployments`. A deployment event links the service to the repository. If the report step is already OK, wait for the next production deployment. |
| Deployment report step | Run the skill `ewake-report-deployments`. |

Do not start a next step. The user makes the decision.
