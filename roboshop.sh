#!/bin/bash


SG_ID="sg-0397ae3d261c3d2e4" # Replace with your actual Security Group ID
AMI_ID="ami-0220d79f3f480ecf5" # Replace with your desired AMI ID
Zone_ID="0760197PITCJBO2DZXK" # Replace with your actual Hosted Zone ID
Domain_Name="devopspractice08.online" # Replace with your actual Domain Name

for instance in "$@"
 do
    instance_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ $instance == "frontend" ]; then
        ip=$(
            aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)

        RECORD_NAME="$Domain_Name"
    else
        ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)

        RECORD_NAME="$instance.$Domain_Name" # devopspractice08.online
    fi


    echo "The IP address: $ip"

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$Zone_ID" \
        --change-batch '
        {
            "Comment": "Updating record",
            "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'"$RECORD_NAME"'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": 
                    [
                    {
                      "Value": "'"$ip"'"
                    }
                    ]
                }
            }
            ]
        }
        '

    
    echo "Record created for $instance"





done