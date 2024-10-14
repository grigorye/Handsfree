package com.gentin.connectiq.handsfree.impl

import android.app.Service
import android.content.Context
import android.content.ContextWrapper
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build

class HeadsetConnectionMonitor(
    base: Context,
    val connectionInvalidated: () -> Unit
) : ContextWrapper(base) {
    fun start() {
        audioManager.registerAudioDeviceCallback(audioDeviceCallback, null)
    }

    fun stop() {
        audioManager.unregisterAudioDeviceCallback(audioDeviceCallback)
    }

    private val audioDeviceCallback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>?) {
            super.onAudioDevicesAdded(addedDevices)
            connectionInvalidated()
        }

        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>?) {
            connectionInvalidated()
            super.onAudioDevicesRemoved(removedDevices)
        }
    }

    fun isHeadsetConnected(): Boolean {
        return isHeadsetConnected(audioManager)
    }

    private val audioManager by lazy { audioManager(this) }
}

fun audioManager(context: Context): AudioManager {
    return context.getSystemService(Service.AUDIO_SERVICE) as AudioManager
}

fun isHeadsetConnected(audioManager: AudioManager): Boolean {
    val audioDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
    val headsetDeviceTypes = mutableListOf(
        AudioDeviceInfo.TYPE_WIRED_HEADSET,
        AudioDeviceInfo.TYPE_HEARING_AID,
        AudioDeviceInfo.TYPE_BLUETOOTH_SCO
    ).apply {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            add(AudioDeviceInfo.TYPE_BLE_HEADSET)
        }
    }.toList()
    for (deviceInfo in audioDevices) {
        if (headsetDeviceTypes.contains(deviceInfo.type)) {
            return true
        }
    }
    return false
}