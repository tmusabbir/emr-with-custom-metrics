#!/bin/bash
set -x -e

IS_MASTER=false
if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
  IS_MASTER=true
fi

if [ "$IS_MASTER" = false ]; then
exit 0
fi

REGION=`curl -s http/://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/'`
HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`

echo $REGION > /tmp/aws-region
echo $HOSTNAME > /tmp/hostname

cd /home/hadoop
aws s3 cp s3://aws-data-analytics-blog/emr-custom-metrics/custom-metrics.sh .
chmod +x custom-metrics.sh

echo '* * * * * sudo /bin/bash -l -c "/home/hadoop/custom-metrics.sh.sh; sleep 30; /home/hadoop/custom-metrics.sh"' > crontab.txt

crontab crontab.txt


