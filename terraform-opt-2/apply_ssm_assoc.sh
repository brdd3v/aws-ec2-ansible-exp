AWS_REGION=eu-central-1
echo "Enter the ID of the SSM association:"
read SSM_ASSOC_ID

aws ssm start-associations-once --association-id $SSM_ASSOC_ID --region=$AWS_REGION

