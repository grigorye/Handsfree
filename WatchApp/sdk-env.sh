#! /bin/bash

latest_sdk_version="7.1.1-2024-04-11-66d0159ae"
stable_sdk_version="7.1.1-2024-04-11-66d0159ae"

developer_key=~/Workbench/Garmin/developer_key

sdks_dir=~/Library/Application\ Support/Garmin/ConnectIQ/Sdks
latest_sdk_root="$sdks_dir/connectiq-sdk-mac-$latest_sdk_version"
stable_sdk_root="$sdks_dir/connectiq-sdk-mac-$stable_sdk_version"

export sdk_root="$latest_sdk_root"
