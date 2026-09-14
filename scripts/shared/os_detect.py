import sys
import platform
import subprocess
import os

def is_windows():
    return sys.platform == "win32"

def get_os_info():
    if not is_windows():
        return {
            "is_windows": False,
            "is_windows_server": False,
            "is_windows_11": False,
            "is_windows_10": False,
            "has_windows_store": False,
            "caption": platform.platform(),
            "build_number": 0,
            "product_type": 0
        }

    caption = platform.platform()
    build_num = 0
    product_type = 1
    is_server = False

    try:
        cmd = ["powershell", "-NoProfile", "-NonInteractive", "-Command",
               "Get-CimInstance Win32_OperatingSystem | Select-Object -Property Caption,BuildNumber,ProductType | ConvertTo-Json"]
        out = subprocess.check_output(cmd, stderr=subprocess.DEVNULL, timeout=5).decode("utf-8")
        import json
        data = json.loads(out)
        caption = data.get("Caption", caption)
        build_num = int(data.get("BuildNumber", 0))
        product_type = int(data.get("ProductType", 1))
        is_server = (product_type in (2, 3)) or ("Server" in caption)
    except Exception:
        pass

    is_win11 = (not is_server) and (build_num >= 22000)
    is_win10 = (not is_server) and (10240 <= build_num < 22000)

    has_store = False
    store_dir = os.path.expandvars(r"%ProgramFiles%\WindowsApps")
    if os.path.exists(store_dir):
        try:
            for item in os.listdir(store_dir):
                if "Microsoft.WindowsStore" in item:
                    has_store = True
                    break
        except Exception:
            pass

    return {
        "is_windows": True,
        "is_windows_server": is_server,
        "is_windows_11": is_win11,
        "is_windows_10": is_win10,
        "has_windows_store": has_store,
        "caption": caption,
        "build_number": build_num,
        "product_type": product_type
    }

def is_windows_server():
    return get_os_info().get("is_windows_server", False)

def is_windows_11():
    return get_os_info().get("is_windows_11", False)

def is_windows_10():
    return get_os_info().get("is_windows_10", False)

def has_windows_store():
    return get_os_info().get("has_windows_store", False)

if __name__ == "__main__":
    import json
    print(json.dumps(get_os_info(), indent=2))
