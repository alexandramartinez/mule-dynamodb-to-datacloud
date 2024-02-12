# Amazon DynamoDB to Salesforce Data Cloud integration in Mule 4

Mule 4 app created to **scan** items from Amazon DynamoDB and insert them in Salesforce Data Cloud.

- Main flow can be found in [dynamodb-to-datacloud.xml](/src/main/mule/dynamodb-to-datacloud.xml)
- Global configurations can be found in [global.xml](/src/main/mule/global.xml)
- Secured/encrypted properties can be found in [secure.config.yaml](/src/main/resources/secure.config.yaml)
- Regular properties can be found in [config.yaml](/src/main/resources/config.yaml)
- DataWeave transformation can be found in [dynamodb-response.dwl](/src/main/resources/dw/dynamodb-response.dwl)
- Example input payload for the DataWeave script can be found in [payload.json](/src/test/resources/dw/dynamodb-response/Playground/inputs/payload.json)
- The encryption key property is called `encryption.key`

## Resources

If you need additional resources to do your configs, check out the following links:

**MuleSoft**
- [How to add JVM/Command-line arguments to the Mule 4 Runtime in Anypoint Code Builder (ACB)](https://www.prostdev.com/post/how-to-add-jvm-command-line-arguments-to-the-mule-4-runtime-in-anypoint-code-builder-acb)
- [How to secure properties before deployment in Anypoint Studio](https://developer.mulesoft.com/tutorials-and-howtos/getting-started/how-to-secure-properties-before-deployment/)
- [Quick guide to secure/encrypt your properties in MuleSoft](https://dev.to/devalexmartinez/quick-guide-to-secureencrypt-your-properties-in-mulesoft-n9k)

**Salesforce**
- [Part 1: Data Cloud + MuleSoft integration - Connected App, Ingestion API & Data Stream settings in Salesforce](https://www.prostdev.com/post/part-1-data-cloud-mulesoft-integration)

**AWS**
- [Managing access keys for IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
- [Getting started with DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html)
- [Getting started with the DataWeave extension for Visual Studio Code](https://developer.mulesoft.com/tutorials-and-howtos/dataweave/dataweave-extension-vscode-getting-started/)

## Run this app locally

Besides making sure you have all the configuration ready in AWS/Salesforce, this is how you have to set up your Mule project to run locally.

1. Download or clone this repo to your local computer
2. Open it in [Studio](https://www.mulesoft.com/platform/studio) or [ACB](https://www.mulesoft.com/platform/api/anypoint-code-builder) (preferably ACB)
3. Add your values to the [config.yaml](/src/main/resources/config.yaml) file
   - `cdp.api.name` - the **Source API Name** from your Ingestion API in Salesforce
   - `cdp.object.name` - the **Object Name** from your Ingestion API / Data Stream in Salesforce
   - `dynamodb.table.name` - the name of the table to scan items from in DynamoDB
4. Add your **encrypted** values to the [secure.config.yaml](/src/main/resources/secure.config.yaml) file
    - `cdp.consumer.key` - the **Consumer Key** from your Connected App in Salesforce
    - `cdp.consumer.secret` - the **Consumer Secret** from your Connected App in Salesforce
    - `salesforce.username` - the username to log in to your Salesforce account
    - `salesforce.password` - the password to log in to your Salesforce account
    - `dynamodb.accessKey` - the Access Key for your AWS account
    - `dynamodb.secretKey` - the Secret Key for your AWS account
5. Modify the DataWeave code in [dynamodb-response.dwl](/src/main/resources/dw/dynamodb-response.dwl) to match your DynamoDB/Data Cloud output/input 
    - The code in the file is an example for my specific use case. Use the two functions (`removeDynamodbKeys` & `flattenObject`) to transform the data, but make sure you map the keys/values to your specific structure
    - If you're using ACB, you can use the DataWeave extension for VS Code to see the preview of your script before deploying
6. Make sure to pass the `encryption.key` property to the runtime (see [resources](#resources) for more info)
7. Run the application locally
8. Send a request to `localhost:8081/sync` to trigger the flow
9. You should receive a **200-OK** response
10. Wait 2-5 minutes for the insertion to be added to Data Cloud

If you're experiencing issues, please make sure your credentials are correct and your Salesforce/AWS settings have been properly set.

You can also raise an issue to this repo in case I missed something in the code.

## Limitations

This is intended to be a simple POC. This app **only** performs the **scan** from the given AWS table and does an **insert (streaming)** to Data Cloud every time you send a request to the `/sync` path.

This app does not perform deletions or queries in Data Cloud. Check out [this GitHub repo](https://github.com/alexandramartinez/datacloud-mulesoft-integration) for delete/query operations.

Since the **Streaming - Insert** operation is being used for Data Cloud, there is a max of 200 records set by Data Cloud. You can implement the [Size-Based Aggregator](https://docs.mulesoft.com/aggregators-module/latest/aggregators-size-example) to the app if you intend to use more than 200 records or switch the operation to **Batch** instead of **Streaming**.