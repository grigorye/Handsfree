package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.AudioManager.GET_DEVICES_ALL
import android.media.AudioManager.GET_DEVICES_OUTPUTS
import android.provider.MediaStore.Audio


fun isHeadsetConnected(context: Context): Boolean {
    val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    val audioDevices = audioManager.getDevices(GET_DEVICES_OUTPUTS)
    val headsetDeviceTypes = arrayOf(
        AudioDeviceInfo.TYPE_WIRED_HEADSET,
        AudioDeviceInfo.TYPE_BLE_HEADSET,
        AudioDeviceInfo.TYPE_HEARING_AID,
        AudioDeviceInfo.TYPE_BLUETOOTH_SCO
    )
    for (deviceInfo in audioDevices) {
        if (headsetDeviceTypes.contains(deviceInfo.type)) {
            return true
        }
    }
    return false
}