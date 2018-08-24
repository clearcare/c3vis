#!/bin/sh
echo "generating aws_config.json..."
export REGION=`curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
export AWS_REGION=$REGION
echo "Region is: $REGION"
cat > aws_config.json <<EOF
  {
    "region": "$REGION"
  }
EOF
echo "starting c3vis..."
npm start
