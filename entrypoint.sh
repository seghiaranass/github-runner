#!/usr/bin/env bash
set -e

# If you want to enforce that these environment variables must be set:
: "${RUNNER_URL?Environment variable RUNNER_URL not set!}"
: "${RUNNER_TOKEN?Environment variable RUNNER_TOKEN not set!}"
# Optionally:
# : "${RUNNER_NAME?Environment variable RUNNER_NAME not set!}"
# : "${RUNNER_LABELS?Environment variable RUNNER_LABELS not set!}"

echo "Configuring GitHub Runner..."
./config.sh \
  --url "${RUNNER_URL}" \
  --token "${RUNNER_TOKEN}" \
  --unattended \
  --replace \
  --name "${RUNNER_NAME:-$(hostname)}" \
  --labels "${RUNNER_LABELS:-docker}"

echo "Runner configured successfully!"

# Start the runner (blocking call)
exec ./run.sh
