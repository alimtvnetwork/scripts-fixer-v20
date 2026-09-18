# Subtask: Ubuntu Cloud CLIs

This subtask covers creating or updating scripts in `scripts/os/ubuntu/` to install AWS CLI, Google Cloud SDK, and Azure CLI on Ubuntu.

## Actionable Steps

1. **AWS CLI** (e.g., `scripts/os/ubuntu/install_aws.sh`):
   - Check if `aws` is installed.
   - If not, download the AWS CLI v2 zip file via `curl`.
   - Unzip and run `./aws/install`.
   - Verify installation.

2. **Google Cloud SDK** (e.g., `scripts/os/ubuntu/install_gcloud.sh`):
   - Check if `gcloud` is installed.
   - If not, add the Cloud SDK distribution URI as a package source.
   - Import the Google Cloud public key.
   - Update apt and `apt-get install -y google-cloud-cli`.

3. **Azure CLI** (e.g., `scripts/os/ubuntu/install_azure.sh`):
   - Check if `az` is installed.
   - If not, download and run the Microsoft signing key script.
   - Add the Azure CLI software repository.
   - Update apt and `apt-get install -y azure-cli`.

4. **Integration**:
   - Ensure these scripts are executable (`chmod +x`).
   - Call them from the main Ubuntu setup script if applicable.
