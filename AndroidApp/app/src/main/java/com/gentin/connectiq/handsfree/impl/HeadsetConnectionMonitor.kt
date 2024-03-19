package com.gentin.connectiq.handsfree.impl

import android.app.Service
import android.content.Context
import android.content.ContextWrapper
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager

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

    fun isHeadsetConnected(): Boolean {
        val audioDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
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

    private val audioManager by lazy { getSystemService(Service.AUDIO_SERVICE) as AudioManager }
}