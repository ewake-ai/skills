---
name: ewake-teach
description: Map the services of this repository to the file `.ewake/repo-metadata.yml` and open a pull request. Use when the user wants to teach Ewake about this repository, or to map its services, key metrics, or dependencies for Ewake.
---

# Teach Ewake about this repository

This skill writes the file `.ewake/repo-metadata.yml`. The file lists the services of this repository, their key metrics, their dependencies, and where they run.

- A **service** is a program that has its code in this repository and sends telemetry.
- **Telemetry** is the traces, logs, and metrics that a service sends to the observability tools.
- The **telemetry name** of a service is the name of the service in its telemetry.
- A **fact** is one entry in the file.
- Two names are **similar** if they are different only in case or in `-`, `_`, or `.`.
- The **source** of a fact is the path of the file that gives the fact. If the user gives or selects the fact, its source is `interview`. If the user keeps a name from a file in place of an Ewake name, the source stays the file. This applies only to a fact that step 2 gives without a question.
- You collect **questions** for the user in steps 2 and 3. You ask all of them in step 4.

A tool name can have a prefix, for example `mcp__ewake__ewake_list_service_names`.

## Rules

- Do not guess a name. Each name comes from a file in this repository or from the user.
- Do not propose a name that no file and no Ewake data gives. Do not use the repository name or a folder name as a telemetry name.
- Do not add a program whose code is in a different repository, for example a program that a service calls.
- Do not write a line number in a source.
- Do not copy a credential to the file, the pull request, or the conversation. Examples are a password, a token, and an API key.
- Change only the file `.ewake/repo-metadata.yml`.
- Show the full change to the user. Commit only after the user agrees.

## The file

```yaml
version: 1
services:
  - name: checkout-api            # the exact name in telemetry
    source: deploy/values.yaml    # a file path, or: interview
    key_metrics:                  # at most 8 per service
      - name: checkout.orders.failed
        signals: errors           # latency | errors | traffic | saturation | business
        source: interview
    depends_on:
      - kind: database            # database | cache | queue
        name: checkout-main
        source: config/database.yml
    runs_on:
      - kind: cluster             # cluster | namespace
        name: prod-eu-west-1
        source: argocd/checkout-api.yaml
```

Use only the fields and values in this example. If you do not know a value, do not write the fact.

## Steps

### 1. Check the connection

Check if a tool with a name that ends with `ewake_list_service_names` is available. If it is not available, recommend the skill `ewake-connect` to the user. Then continue without step 3.

### 2. Read the repository

1. If `.ewake/repo-metadata.yml` exists, keep each fact in it that has `source: interview`. Do not change a kept fact. Do not ask again for it. Do not keep the other facts in the file.
   - A kept fact replaces a fact from a file with a similar name. The two facts must have the same service and the same type. For example, a kept database `checkout_main` replaces the database `checkout-main`.
   - If you cannot find the service of a kept fact, add a question about it. The user can keep, move, or remove the fact.
2. Find each service and its telemetry name. Search for `DD_SERVICE`, `OTEL_SERVICE_NAME`, `service.name`, and the setup of the tracer or the metrics client. If two files give different telemetry names, add a question.
3. Find the key metrics of each service. A key metric shows a problem with the service. Use the metrics in the alert rules and the monitor definitions. If the repository has no alert rules or monitor definitions, add a question about the metric names in the code.
4. Find the databases, caches, and queues that each service uses. Search the configuration, the infrastructure code, and the code that creates each client. Use the production name. A local file, for example `docker-compose.yml`, does not give the production name.
5. Find the clusters and the namespaces where each service runs. Search the deployment manifests, the Helm values, the Argo CD or Flux files, and the CI deployment job.

### 3. Compare with Ewake

If an Ewake tool returns an authorization error, recommend the skill `ewake-connect` to the user. Then go to step 4.

1. Get the repository name from the command `git remote get-url origin`.
2. Call `ewake_list_service_names` with `search` set to each telemetry name.
3. Call `ewake_load_cypher_skill` one time. It gives the graph schema and example queries.
4. Use `ewake_run_cypher_query` to find:
   - the services that Ewake links to this repository
   - the metrics that Ewake links to each service, and the monitors that watch these metrics
   - the databases, caches, and queues that each service uses
   - the clusters and the namespaces where each service runs

   Write each query from the graph schema. Do not guess the name of a label or of a relationship.
5. Compare each name in your facts with the names from Ewake. If two names are different only in case, they are the same name, not a difference. Keep the spelling of the repository. Ewake writes a database, cache, queue, cluster, or namespace as `<kind>:<name>`. Compare only the part after the colon.
6. Find each difference:
   - **Ewake does not have the name.** Keep the name. Show the difference to the user in step 4. The Ewake data is not complete.
   - **Ewake has a similar name**, for example `checkout_main` for `checkout-main`. Add a question. The user selects one name. If the name is in a kept fact, show the difference. Do not add a question.
   - **Only Ewake gives the fact**, for example a metric that a monitor watches. Add a question that proposes the fact. Propose a service only if this repository has its code.

### 4. Ask the user

1. Send one message to the user. Show each difference with Ewake. Ask all the questions.
2. Ask only for facts that the repository and Ewake do not give.
3. If the user does not know the telemetry name of a service, do not add the service.
4. With a connection, compare each name that the user gives with the names from Ewake, as in step 3. Ask again only about a new difference.
5. If the user replaces a name from a file with an Ewake name that is not similar, keep both facts. Write this in the report.

### 5. Write the file

Write `.ewake/repo-metadata.yml` with the facts from steps 2 to 4. If you change nothing, tell the user and stop.

### 6. Open the pull request

1. Write a report with these items:
   - Whether you compared the facts with Ewake.
   - Each service, and the source of its telemetry name.
   - Each difference with Ewake, and the selection of the user.
   - Each fact that has `source: interview`.
   - Each service that is not in the file because no one knows its telemetry name.
   - Each fact that is still missing.
2. Show the full change and the report to the user.
3. After the user agrees, create a branch.
4. Commit only the file `.ewake/repo-metadata.yml`.
5. Open a pull request. Use the report as its description.
