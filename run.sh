#!/bin/sh
echo "generating aws_config.json..."
export AWS_DEFAULT_REGION=`curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
export AWS_REGION=$AWS_DEFAULT_REGION
echo "Region is: $AWS_DEFAULT_REGION"
cat > aws_config.json <<EOF
  {
    "region": "$AWS_DEFAULT_REGION"
  }
EOF
echo "starting c3vis..."
npm start
