# Deploy the Emblem Giving Website using a Cloud Run Emulator
##
This tutorial shows you how to deploy the Emblem Giving website to Cloud Run using a local Cloud Run Emulator.

The Cloud Run Emulator comes built in to Cloud Shell. It allows you to configure an environment that is representative of your service running on Cloud Run, without incurring charges on your GCP billing account.

For the best experience, launch this tutorial as an interactive walkthrough on Cloud Shell: [Open in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblemv&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/website.md)
Let's get started!

## Set up Cloud Shell workspace
First, let's open the Emblem Giving website as the Cloud Shell [Workspace](https://cloud.google.com/shell/docs/workspaces).

1. Launch [Cloud Shell](shell.cloud.google.com) and clone the Emblem Giving repo:
```
git clone https://github.com/GoogleCloudPlatform/emblem.git && cd emblem
``` 

1. Open the website directory as the Cloud Shell Workspace by running the following command in the terminal:
```bash
cloudshell open-workspace website
```

## Deploy to Cloud Run Emulator

1. Click the <walkthrough-editor-spotlight spotlightId="cloud-code-status-bar">Cloud Code menu</walkthrough-editor-spotlight> on the status bar.

2. Select <walkthrough-editor-spotlight spotlightId="cloud-code-run-on-cloud-run-emulator">Run on Cloud Run Emulator</walkthrough-editor-spotlight> from the menu options. This launches the "Run/Debug on Cloud Run Emulator" wizard.

3. Click **Run**.    

The settings from the Run/Debug wizard are stored in <walkthrough-editor-open-file filePath='./.theia/launch.json'>launch.json</walkthrough-editor-open-file>. Subsequent deploys to Cloud Run will use these configurations.

The <walkthrough-editor-spotlight spotlightId="output">Output</walkthrough-editor-spotlight> window will display logs from the Cloud Run deployment.

4. If prompted, authorize gcloud to make API calls.

5. When the deployment is finished, the website's URL will be displayed in the output. Click the URL to view the deployed website for Emblem Giving.

## Make changes with iterative development
The Cloud Run Emulator uses skaffold behind the scenes for iterative development.

Let's make a simple change to see this in action. Since our website isn't connected to the API, we'll populate sample data into the website.

1. Open the file <walkthrough-editor-open-file filePath='./views/campaigns.py'>`views/campaigns.py`</walkthrough-editor-open-file>.

2. Import the sample data on <walkthrough-editor-select-line filePath='./views/campaigns.py' startLine=15 startCharacterOffset=0 endLine=16 endCharacterOffset=0>line 16</walkthrough-editor-select-line> by adding the line of code below:
```
from sample_data import SAMPLE_CAMPAIGNS
```

3. Replace the API request on <walkthrough-editor-select-line filePath='./views/campaigns.py' startLine=28 startCharacterOffset=16 endLine=28 endCharacterOffset=59>line 29</walkthrough-editor-select-line> with the variable `SAMPLE_CAMPAIGNS`. The resulting method should look like this:
```
def list_campaigns():
  campaigns = SAMPLE_CAMPAIGNS
  return render_template("home.html", campaigns=campaigns)

```

You'll be able to see the automatic rebuild and re-deploy of the application in the Output window. Once the deploy has finished, click the url to see the sample data populated in your website. 

## Conclusion
<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
Congratulations! You've successfully deployed the Emblem Giving website using Cloud Run.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

Next steps: 
- Check out instructions on running the [Emblem Giving API on Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/api.md) 