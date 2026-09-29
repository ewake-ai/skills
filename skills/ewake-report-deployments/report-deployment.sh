#!/bin/sh
# Reports one production deployment to Ewake. Always exits 0: a failed report never fails the deployment.
# Inputs: EWAKE_API_KEY, EWAKE_ARTIFACT_NAME, EWAKE_REPOSITORY (owner/name), EWAKE_REPOSITORY_URL,
# EWAKE_COMMIT_SHA (default: git HEAD), EWAKE_API_URL (default: https://api.ewake.ai).

if [ -z "${EWAKE_API_KEY:-}" ]; then
  echo "Ewake: EWAKE_API_KEY is not set. No deployment report sent."
  exit 0
fi

commit_sha="${EWAKE_COMMIT_SHA:-$(git rev-parse HEAD 2>/dev/null)}"
timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# No JSON escaping: names, URLs and SHAs hold no quotes. A bad value gets a 400, not a failed deployment.
body=$(printf '{"timestamp":"%s","repository":"%s","repositoryUrl":"%s","artifactName":"%s","commitSha":"%s","source":"ci"}' \
  "$timestamp" "${EWAKE_REPOSITORY:-}" "${EWAKE_REPOSITORY_URL:-}" "${EWAKE_ARTIFACT_NAME:-}" "$commit_sha")

api_url="${EWAKE_API_URL:-https://api.ewake.ai}"
api_url="${api_url%/}"

# The key goes to curl on stdin (printf is a shell builtin), so it never shows in the process list.
response=$(printf 'header = "Authorization: Bearer %s"\n' "$EWAKE_API_KEY" |
  curl -sS --max-time 10 -K - -w ' (HTTP %{http_code})' -X POST \
    "${api_url}/api/v1/events/deployment" \
    -H "Content-Type: application/json" \
    -d "$body")

case "$response" in
  *'(HTTP 202)')
    echo "Ewake: deployment reported. $response"
    ;;
  *)
    echo "Ewake: deployment report failed: $response. The deployment continues."
    ;;
esac

exit 0
