#! /bin/bash

sdk_version=$(cat "$src_root/sdk-version.txt")

developer_key="${CIQ_DEV_KEY:-$src_root/../../Handsfree-Publishing/keys/developer_key}"

sdks_dir=~/Library/Application\ Support/Garmin/ConnectIQ/Sdks
sdk_root="${CIQ_SDK_ROOT:-$sdks_dir/connectiq-sdk-mac-$sdk_version}"

export sdk_root
