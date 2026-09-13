import os
import sys
import argparse
import re
import json
from pathlib import Path

# Ensure strict UTF-8 encoding
sys.stdout.reconfigure(encoding="utf-8")

def list_folder(folder_path, extensions=None):
    folder = Path(folder_path)
    if not folder.exists() or not folder.is_dir():
        print(f"Error: {folder_path} is not a valid directory.")
        return

    ext_list = [ext.strip() for ext in extensions.split(',')] if extensions else None
    
    for root, _, files in os.walk(folder):
        for file in files:
            file_path = Path(root) / file
            if ext_list:
                if any(file.endswith(ext) for ext in ext_list):
                    print(file_path)
            else:
                print(file_path)

def read_file(file_path, max_bytes=None):
    path = Path(file_path)
    if not path.exists() or not path.is_file():
        print(f"Error: {file_path} is not a valid file.")
        return
    
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read(max_bytes if max_bytes else -1)
        print(content)

def search_pattern(pattern, folder_path):
    regex = re.compile(pattern)
    folder = Path(folder_path)
    
    if not folder.exists() or not folder.is_dir():
        print(f"Error: {folder_path} is not a valid directory.")
        return

    for root, _, files in os.walk(folder):
        for file in files:
            file_path = Path(root) / file
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    for line_num, line in enumerate(f, 1):
                        if regex.search(line):
                            print(f"{file_path}:{line_num}: {line.strip()}")
            except Exception as e:
                pass

def main():
    parser = argparse.ArgumentParser(description="Fast File Reader")
    parser.add_argument("--list-folder", type=str, help="List files in a folder")
    parser.add_argument("--ext", type=str, help="Comma separated list of extensions to filter by")
    parser.add_argument("--read-file", type=str, help="Read a file")
    parser.add_argument("--max-bytes", type=int, help="Maximum bytes to read")
    parser.add_argument("--search-pattern", type=str, help="Search for a regex pattern")
    parser.add_argument("--path", type=str, help="Folder path for search")
    
    args = parser.parse_args()
    
    if args.list_folder:
        list_folder(args.list_folder, args.ext)
    elif args.read_file:
        read_file(args.read_file, args.max_bytes)
    elif args.search_pattern and args.path:
        search_pattern(args.search_pattern, args.path)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
