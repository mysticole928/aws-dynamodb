aws dynamodb create-table \
    --endpoint-url http://localhost:8000 \
    --table-name sd_music \
    --attribute-definitions \
        AttributeName=label,AttributeType=S \
        AttributeName=number,AttributeType=S \
        AttributeName=title,AttributeType=S \
    --key-schema \
        AttributeName=label,KeyType=HASH \
        AttributeName=number,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --global-secondary-indexes 'IndexName=song_title,KeySchema=[{AttributeName=title,KeyType=HASH}],Projection={ProjectionType=KEYS_ONLY}'
