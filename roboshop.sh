#!/bin/bash
SG_ID=" sg-0397ae3d261c3d2e4" # Replace with your actual Security Group ID
AMI_ID="ami-0220d79f3f480ecf5" # Replace with your desired AMI ID

for instance in $@

do
    instance_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3 .micro \
    --security-group-ids $SG_ID \ 
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \ 
    --output text)

    if [ $instance == "frontend" ]; then
        ip=$ (
           aws ec2 describe-instances \ 
           --instance-ids $instance_ID\ 
           --query 'Reservations[0].Instances[0].PublicIpAddress' \
        )
        else
        ip=$ (
           aws ec2 describe-instances \ 
           --instance-ids $instance_ID\ 
           --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        )
        else



    fi





done