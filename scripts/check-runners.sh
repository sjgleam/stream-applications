#!/usr/bin/env bash
SCDIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
SCDIR=$(realpath $SCDIR)
PARENT=$(realpath $SCDIR/..)
SCALING=$(jq '.scdf_pro_gh_runners.runner_scaling' $PARENT/config/defaults.json | sed 's/\"//g')
if [ "$SCALING" == "auto" ]; then
  echo "Auto scaling:"
  kubectl get horizontalrunnerautoscalers
fi
echo ""
echo "RunnerDeployments:"
DEPLOYMENTS=$(kubectl get rdeploy)
echo "$DEPLOYMENTS"
echo ""
echo "Runners:"
RUNNER_DEPLOYMENTS=$(echo "$DEPLOYMENTS" | grep -F "runner" | awk '{print $1}')
for deployment in $RUNNER_DEPLOYMENTS; do
  kubectl get runners -l runner-deployment-name=$deployment --output=json | jq '.items | map(.status) | group_by(.phase,.ready) | map({ "deployment": '"\"$deployment\""', "count": length, "phase": .[0].phase})'
done