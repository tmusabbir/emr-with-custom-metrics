# Amazon EMR Automatic Scaling with Custom Metrics

This writeup is to demonstrate how you can use feed additional metrics from your Amazon EMR cluster and later use
 those metrics to configure [automatic scaling](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-automatic-scaling.html). Ideally, for YARN-based application, [EMR Managed Scaling](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-scaling.html) can handle majority of the scaling needs. However, if your application doesn't run on YARN or you want to use custom metrics, you can follow this solution to get an idea how you can achieve that.
  
Note: ⚠️ Please use this solution as a reference, do not use this solution in production without testing and
 configuring based on your use case.

## Feeding Additional Metrics to AWS CloudWatch

Amazon EMR Automatic Scaling policy is dependent on CloudWatch metrics, so if you want to  scale out and scale in
core node and task nodes based on a specific value, that value needs to be pushed to CloudWatch. Once, the CloudWatch
 receives that value, then you can write the automatic scaling policy using those values. In this example
 , I'm using YARN Core Available Percentage to configure my autoscaling policy. You can check [Monitor Metrics with CloudWatch](https://docs.aws.amazon.com/emr/latest/ManagementGuide/UsingEMR_ViewingMetrics.html) to see the list of available
 EMR metrics on CloudWatch. I'm using core percentage just for an example, you can use any other value depending on
  your requirement. 
     
I have a bash script [custom-metrics.sh](scripts/custom-metrics.sh) that executes on the EMR cluster every 30 seconds
 through a cron job. Inside that script, I'm leveraging [ResourceManager REST
 API’s](https://hadoop.apache.org/docs/r2.8.5/hadoop-yarn/hadoop-yarn-site/ResourceManagerRest.html) to get YARN
  metrics. From all the metrics, I am parsing two different data points **availableVirtualCores** and
   **totalVirtualCores** to calculate the **YARNCoreAvailablePercentage** value. Once I get the value, I use
    [AWS CLI](https://aws.amazon.com/cli/) to publish the value to CloudWatch.

## Using Custom CloudWatch Metrics to configure EMR Automatic Scaling

## Demo