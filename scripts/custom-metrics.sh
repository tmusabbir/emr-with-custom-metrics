#!/bin/bash
set -x -e

REGION=`cat /tmp/aws-region`
HOSTNAME=`cat /tmp/hostname`

RESPONSE=`curl -s $HOSTNAME:8088/ws/v1/cluster/metrics`
CLUSTER_ID=`ruby -e "puts '\`grep jobFlowId /mnt/var/lib/info/job-flow.json\`'.split('\"')[-2]"`

AVAILABLE_CORE=`echo $RESPONSE | jq -r .clusterMetrics.availableVirtualCores`
TOTAL_CORE=`echo $RESPONSE | jq -r .clusterMetrics.totalVirtualCores`
CORE_AVAILABLE_PERCENTAGE=$(echo "scale=2; $AVAILABLE_CORE *100 / $TOTAL_CORE" | bc)

aws cloudwatch put-metric-data --metric-name YARNCoreAvailablePercentage --namespace AWS/ElasticMapReduce --unit Percent --value $CORE_AVAILABLE_PERCENTAGE --dimensions JobFlowId=$CLUSTER_ID --region $REGION