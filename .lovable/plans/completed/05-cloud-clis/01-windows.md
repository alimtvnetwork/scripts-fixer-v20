# Subtask: Windows Cloud CLIs

This subtask covers updating the Windows entry point (`run.ps1`) to include the installation of AWS CLI, Google Cloud SDK, and Azure CLI.

## Actionable Steps

1. **AWS CLI**:
   - Check if `aws` is available in `PATH`.
   - If not, download the AWS CLI MSI installer using `Invoke-WebRequest`.
   - Install using `msiexec.exe /i awscliv2.msi /qn`.
   - Verify installation.

2. **Google Cloud SDK**:
   - Check if `gcloud` is available in `PATH`.
   - If not, download the Google Cloud SDK installer.
   - Install silently using the provided installer arguments (e.g., `/S`).
   - Ensure `gcloud` is added to the `PATH`.

3. **Azure CLI**:
   - Check if `az` is available in `PATH`.
   - If not, download the Azure CLI MSI installer.
   - Install using `msiexec.exe /i azure-cli.msi /qn`.
   - Verify installation.

4. **Integration**:
   - Update `run.ps1` to call these installation functions sequentially.
