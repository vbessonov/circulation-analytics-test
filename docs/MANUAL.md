# Create SimplyE Analytics Testbed Manually

These are the steps required to create a testbed manually:

## Creating an S3 bucket
### Creating a bucket
1. Sign in to the AWS Management Console, open the Amazon S3 console at https://console.aws.amazon.com/s3/ and click on **Create bucket** button:
  ![Create a new S3 bucket](images/01-create-s3-bucket.png "Create a new S3 bucket")

2. In the newly opened dialog enter a new bucket name:
  ![Create a new S3 bucket](images/02-create-s3-bucket.png "Create a new S3 bucket")

> :information_source: To be able to make the name unique you may want to add a [GUID](https://www.guidgenerator.com/online-guid-generator.aspx) to its end.

3. Scroll to the end of the page and click on **Create bucket**:
  ![Create a new S3 bucket](images/03-create-s3-bucket.png "Create a new S3 bucket")

4. After the bucket is created, you'll be redirected to the list of all available buckets.
Find the newly created bucket in the list and click on its name:
  ![Create a new S3 bucket](images/04-create-s3-bucket.png "Create a new S3 bucket")

### Creating required folders
5. In the new window showing bucket's settings click on **Create folder** button:
  ![Create a new folder in the S3 bucket](images/05-create-folder-in-s3-bucket.png "Create a new folder in the S3 bucket")

6. In the folder's setting window enter the name: **json-input**. It's the folder that will be storing JSON files containing Circulation Manager analytics events:
  ![Create a new folder in the S3 bucket](images/06-create-folder-in-s3-bucket.png "Create a new folder in the S3 bucket")

Repeat steps 5 - 6 and create the following folder structure:
```
|- athena
|- glue
   |- scripts
   |- temporary
|- json-input
|- parquet-output
 ```

7. After creating all the folders, the bucket's folder structure should look like as it's shown on the screenshot below:
  ![S3 bucket folder structure](images/07-s3-bucket-structure.png "S3 bucket folder structure")

### Uploading test data to the bucket
8. Now upload test files to the bucket. Go to **json-input** folder and click on **Upload** button:
  ![Upload test files to the bucket](images/08-upload-json-files-to-s3-bucket.png "Upload test files to the bucket")

9. Drag and drop the files from [test-data](../test-data) folder:
  ![Upload test files to the bucket](images/09-upload-json-files-to-s3-bucket.png "Upload test files to the bucket")

10. After adding all the files scroll down to the end of the page and click on **Upload** button:
  ![Upload test files to the bucket](images/10-upload-json-files-to-s3-bucket.png "Upload test files to the bucket")

## Creating a Glue crawler for json-input folder
### Creating a new crawler
11. Open the AWS Glue console at https://console.aws.amazon.com/glue/, choose **Crawlers** in the navigation pane and then click **Add crawler**:
  ![Create AWS Glue crawler for json-input folder](images/08-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

12. Enter the name of the new crawler and click on **Next**:
  ![Create AWS Glue crawler for json-input folder](images/09-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

13. Select **Crawl new folders** and click on **Next**:
  ![Create AWS Glue crawler for json-input folder](images/10-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

14. Select **S3** data store and choose **json-input** folder as **Input path**:
  ![Create AWS Glue crawler for json-input folder](images/11-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

15. Let Glue to generate a new IAM role, specify its name and click on **Next**:
  ![Create AWS Glue crawler for json-input folder](images/12-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

16. Choose **Run on demand** as **Frequency** and click on **Next**:
  ![Create AWS Glue crawler for json-input folder](images/13-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

17. Click on **Add database**:
  ![Create AWS Glue crawler for json-input folder](images/14-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

18. Enter the name of the database and click on **Create**:
  ![Create AWS Glue crawler for json-input folder](images/15-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

19. Check **Update all new and existing partitions with metadata from the table**:
  ![Create AWS Glue crawler for json-input folder](images/16-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

20. Click on **Next** until the last page of the wizard and then click on **Finish**.

### Running the crawler
21. Select the newly created crawler in the list and click on **Run** to trigger it. After running you should be able to see the message saying that it completed and a new table has been successfully created:
  ![Create AWS Glue crawler for json-input folder](images/17-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

### Updating the schema created by the crawler
22. Select **Tables** on the left, choose **json_input** and click on **Edit schema**:
  ![Create AWS Glue crawler for json-input folder](images/18-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

23. Select **Tables** on the left, choose **json_input** and click on **Edit schema**:
  ![Create AWS Glue crawler for json-input folder](images/18-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")

24. Walk through all the columns and change data type to `timestamp` for the following columns:
* **issued**
* **end**
* **availability_time**
* **start**
* **published**
  ![Create AWS Glue crawler for json-input folder](images/19-create-glue-json-input-crawler.png "Create AWS Glue crawler for json-input folder")
After finishing scroll down to the end of the page and click on **Save**.

## Creating a Glue job for converting json-input data to the Apache Parquet format
### Creating an IAM policy for the Parquet converter
25. Open the IAM console at https://console.aws.amazon.com/iam/, in the navigation pane on the left choose **Policies**:
  ![Create a new IAM policy](images/20-create-new-iam-policy.png "Create a new IAM policy")

26. Click on **Create policy**:
  ![Create a new IAM policy](images/21-create-new-iam-policy.png "Create a new IAM policy")

27. Switch to **JSON** tab and insert the following:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::<cm-analytics-bucket>/json-input*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::<cm-analytics-bucket>/glue*",
                "arn:aws:s3:::<cm-analytics-bucket>/parquet-output*"
            ]
        }
    ]
}
```
where `<cm-analytics-bucket>` must be replaced with the name of the bucket created in 1 - 3.
  ![Create a new IAM policy](images/22-create-new-iam-policy.png "Create a new IAM policy")

28. Enter the new policy's name on the review page and click on **Finish**:
  ![Create a new IAM policy](images/23-create-new-iam-policy.png "Create a new IAM policy")

### Creating an IAM role for the Parquet converter
29. In the navigation pane on the left choose **Roles** and click on **Create role**:
  ![Create a new IAM role](images/23-create-new-iam-role.png "Create a new IAM role")

30. Choose Glue as a trusted entity and go to the next page:
  ![Create a new IAM role](images/24-create-new-iam-role.png "Create a new IAM role")

31. Choose the following policies:
* **AWSGlueServiceRole**
* **AWSGlueServiceRole-CMAnalyticsParquetConverter**, the policy created in 21 - 24:
  ![Create a new IAM role](images/25-create-new-iam-role.png "Create a new IAM role")

32. Enter the new role's name and click on **Create role**:
  ![Create a new IAM role](images/26-create-new-iam-role.png "Create a new IAM role")

### Creating a Glue job
33. Open the AWS Glue console at https://console.aws.amazon.com/glue/, choose Crawlers in the navigation pane and then click **Add job**:
  ![Create a Glue job](images/27-create-new-glue-job.png "Create a Glue job")

34. Enter the name of the new job, select the role created in 29 - 32:
  ![Create a Glue job](images/28-create-new-glue-job.png "CreaCreateting a Glue job")

35. Then scroll down to **Advanced properties**, enable **Job bookmark** and scroll down to the next page of the wizard.

36. Choose **json-input** as a data source and click on **Next**:
  ![Create a Glue job](images/29-create-new-glue-job.png "Create a Glue job")

37. Leave the tranform type as is and click on **Next**:
  ![Create a Glue job](images/30-create-new-glue-job.png "Create a Glue job")

38. Choose Parqeut and **parquet-output** as a target type and target path respectively:
  ![Create a Glue job](images/31-create-new-glue-job.png "Create a Glue job")

## Creating a Glue crawler for parquet-output
### Creating a new Glue crawler
39. In the navigation bar on the left select **Crawlers** again and click on **Add crawler**:
  ![Create a Glue crawler for parquet-output](images/32-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

40. Enter the name and click on **Next**:
  ![Create a Glue crawler for parquet-output](images/33-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

41. Specify source type and click on **Next**:
  ![Create a Glue crawler for parquet-output](images/34-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

42. Specify **parquet-output** as a target data source:
  ![Create a Glue crawler for parquet-output](images/35-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

43. Specify **parquet-output** as a target data source:
  ![Create a Glue crawler for parquet-output](images/35-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

44. Let Glue create a new IAM role:
  ![Create a Glue crawler for parquet-output](images/37-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

45. Select **cm-analytics** as a database where the crawler will reside the output table:
  ![Create a Glue crawler for parquet-output](images/38-create-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

46. Run the newly created crawler:
  ![Create a Glue crawler for parquet-output](images/39-run-parquet-output-crawler.png "Create a Glue crawler for parquet-output")

## Set up AWS Athena
47. Open the Athena console at https://console.aws.amazon.com/athena/ and start setting it up:
  ![Set up AWS Athena](images/40-set-up-athena-storage.png "Set up AWS Athena")

48. Set **athena** folder as query result location and click on **Save**:
  ![Set up AWS Athena](images/41-set-up-athena-storage.png "Set up AWS Athena")

49. Run the query to ensure that Athena has been set up correctly:
  ![Query AWS Athena](images/42-query-athena.png "Query AWS Athena")

## Setting up QuickSight
50. Create a new analysis in QuickSight:
  ![Set up a new dataset in QuickSight](images/43-quicksight-set-up-new-data-set.png "Set up a new dataset in QuickSight")

51. Create a new dataset:
  ![Set up a new dataset in QuickSight](images/44-quicksight-set-up-new-data-set.png "Set up a new dataset in QuickSight")

52. Set up a new Athena dataset and select **cm-analytics** database:
  ![Set up a new dataset in QuickSight](images/45-quicksight-set-up-new-data-set.png "Set up a new dataset in QuickSight")

53. Select **parquet-output** table:
  ![Set up a new dataset in QuickSight](images/46-quicksight-set-up-new-data-set.png "Set up a new dataset in QuickSight")

54. Don't use SPICE, directly query data:
  ![Set up a new dataset in QuickSight](images/47-quicksight-set-up-new-data-set.png "Set up a new dataset in QuickSight")

55. Change to **N. Virginia** regioon and click on **Manage QuickSight**:
  ![Set up QuickSight security settings](images/48-quicksight-set-up-security-settings.png "Set up QuickSight security settings")

56. Click on **Security & permissions**:
  ![Set up QuickSight security settings](images/49-quicksight-set-up-security-settings.png "Set up QuickSight security settings")

57. Under **QuickSight access to AWS services** click on **Add or remove**:
  ![Set up QuickSight security settings](images/50-quicksight-set-up-security-settings.png "Set up QuickSight security settings")

58. Scroll down to **Amazon S3** and click on **Select buckets**:
  ![Set up QuickSight security settings](images/51-quicksight-set-up-security-settings.png "Set up QuickSight security settings")

59. Select the bucket created in **Creating an S3 bucket** and click on **Finish**:
  ![Set up QuickSight security settings](images/52-quicksight-set-up-security-settings.png "Set up QuickSight security settings")

60. Click on **Update**:
  ![Set up QuickSight security settings](images/53-quicksight-set-up-security-settings.png "Set up QuickSight security settings")

61. Try to create a new dashboard:
  ![Create a QuickSight visual](images/54-quicksight-set-up-new-dashboard.png "Create a QuickSight visual")