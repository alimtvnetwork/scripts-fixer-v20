import os
import shutil

src = r"C:\Users\Administrator\.gemini\antigravity\brain\47c29808-12fb-4bc5-9fa1-523c39e6f96d\.user_uploaded\media_1787735736562.png"
dst_dir = r".lovable\assets\screenshots"
dst = os.path.join(dst_dir, "02-run-sh-dark-issue.png")

os.makedirs(dst_dir, exist_ok=True)
if os.path.exists(src):
    shutil.copy(src, dst)
    print("Image copied successfully.")
else:
    print("Source image not found.")
