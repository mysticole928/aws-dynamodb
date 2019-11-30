# Creating a Global Secondary Index using the CLI

Earlier this week, I had an idea for a project.  As part of the project, I have a long-term goal to make it serverless on AWS using Lambda and DynamoDB.

DynamoDB would help me avoid using temporary files.  This, in itself, is great.  However, I want to do my development locally.  It will take me a few iterations before I'm ready to deploy to the cloud.

I also know that I'm going to need a secondary index for lookups.  That has been a problem.  First, I had to choose between a local secondary index and a global secondary index.  Based on the documentation and various web searches, I picked global indexes.  They can be added later, as needed.

The challenge has been how to create a global secondary index (GSI) using the command line.  The documentation has been terribly inadequate.  After a week's worth of trial and error, I figured out how to do it.

## TL;DR - This one works

```bash
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
```

This is the part that fixed it:

```bash
-global-secondary-indexes 'IndexName=song_title,KeySchema=[{AttributeName=title,KeyType=HASH}],Projection={ProjectionType=KEYS_ONLY}'
```

One of the AWS documentation pages has this as an exampe:

```bash
aws dynamodb update-table \
    --table-name Music \
    --attribute-definitions AttributeName=AlbumTitle,AttributeType=S \
    --global-secondary-index-updates \
    "[{\"Create\":{\"IndexName\": \"AlbumTitle-index\",\"KeySchema\":[{\"AttributeName\":\"AlbumTitle\",\"KeyType\":\"HASH\"}], \
    \"ProvisionedThroughput\": {\"ReadCapacityUnits\": 10, \"WriteCapacityUnits\": 5      },\"Projection\":{\"ProjectionType\":\"ALL\"}}}]" 
```
    
Notice that it's done as part of a table update.  I wanted information about table creation.  (Mostly because I wanted to know how to do it.  I'm not lazy, I'm efficent.  It's different.)
    
Also, the GSI syntax is in JSON.  I have no problem with this.  However, I like consistency.  Either write it *all* in JSON or *all* in the so-called shorthand syntax.
    
Here's the example I found in the AWS documentation:
    
```bash
IndexName=string,KeySchema=[{AttributeName=string,KeyType=string},{AttributeName=string,KeyType=string}],Projection={ProjectionType=string,NonKeyAttributes=[string,string]},ProvisionedThroughput={ReadCapacityUnits=long,WriteCapacityUnits=long} ...
```
   
## JSON: All or nothing?
    
I have no problem working with JSON.  
It just frustrates me to have to mix and match when I don't think I should have to.
    
Also, I tried this route by starting with the command:
    
```bash
aws dynamodb create-table --generate-cli-skeleton
```
    
The output starts with:
    
```bash
{
"AttributeDefinitions": [
    {
        "AttributeName": "",
        "AttributeType": "S"
    }
],
"TableName": "",
"KeySchema": [
    {
        "AttributeName": "",
        "KeyType": "HASH"
    }
],
...
```
    
I've looked in the documentation but not found anything about that first key/value pair.  
I have no idea what is supposed to be.  I got documentation fatigue trying to find it.
    
## My Aha! moment
   
On StackOverflow, I found an answer.  I've tried to replace my steps to give credit where it is due.
    
No luck.
    
I still had to use JSON.  The trick, as it is, is to put the content after --global-secondary-indexes in quotes.
    
Either of these methods work:
    
```bash
--global-secondary-indexes 'IndexName=song_title,KeySchema=[{AttributeName=title,KeyType=HASH}],Projection={ProjectionType=KEYS_ONLY}'
```
    
-or-
    
 ```bash
 --global-secondary-indexes \
  'IndexName=song_title,KeySchema=[{AttributeName=title,KeyType=HASH}],Projection={ProjectionType=KEYS_ONLY}'
 ```
    
 All of the GSI info must be on its own line.  (Indents are fine.)
 
 Also, the attribute in the GSI's key schema must be declared in the table's attributes.  It is not created automatically.
    
 
    
