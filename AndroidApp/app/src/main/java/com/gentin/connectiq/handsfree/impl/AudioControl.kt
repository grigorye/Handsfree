package com.gentin.connectiq.handsfree.impl

import android.app.Service
import android.content.Context
import android.content.ContextWrapper
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi

interface AudioControl {
    fun toggleSpeaker(on: Boolean)
    fun mute(on: Boolean)
    fun isMuted(): Boolean
    fun setAudioVolume(relVolume: RelVolume)
    fun audioVolume(): RelVolume
}

class AudioControlImp(base: Context?) : ContextWrapper(base), AudioControl {
    companion object {
        private val TAG = AudioControlImp::class.java.simpleName
    }

    override fun toggleSpeaker(on: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            toggleSpeakerNew(on)
        } else {
            toggleSpeakerPreS(on)
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun toggleSpeakerNew(on: Boolean) {
        val audioManager = getSystemService(Service.AUDIO_SERVICE) as AudioManager
        Log.d(TAG, "audioMode: ${audioManager.mode}")
        val speaker = audioManager.availableCommunicationDevices.first {
            it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
        }
        if (on) {
            val succeeded = audioManager.setCommunicationDevice(speaker)
            Log.d(TAG, "toggleSpeakerOn.succeeded: $succeeded")
        } else {
            if (audioManager.communicationDevice == speaker) {
                audioManager.clearCommunicationDevice()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun toggleSpeakerPreS(on: Boolean) {
        val audioManager = getSystemService(Service.AUDIO_SERVICE) as AudioManager
        val isSpeakerOn = audioManager.isSpeakerphoneOn
        Log.d(TAG, "isSpeakerphoneOn: $isSpeakerOn")
        audioManager.isSpeakerphoneOn = on
    }

    override fun mute(on: Boolean) {
        val audioManager = getSystemService(Service.AUDIO_SERVICE) as AudioManager
        audioManager.isMicrophoneMute = on
        if (audioManager.isMicrophoneMute != on) {
            Log.e(TAG, "muteFailed($on)")
        } else {
            Log.d(TAG, "muteSucceeded($on)")
        }
    }

    override fun isMuted(): Boolean {
        val audioManager = getSystemService(Service.AUDIO_SERVICE) as AudioManager
        return audioManager.isMicrophoneMute
    }

    override fun setAudioVolume(relVolume: RelVolume) {
        Log.d(TAG, "settingAudioVolume: $relVolume")
        val audioManager = getSystemService(Service.AUDIO_SERVICE) as AudioManager
        val stream = communicationAudioStream(audioManager)
        Log.d(TAG, "stream: $stream")
        val maxVolume = audioManager.getStreamMaxVolume(stream)
        val minVolume = 1 // audioManager.getStreamMinVolume(stream)
        Log.d(TAG, "volumeRange: $minVolume...$maxVolume")
        val volume = minVolume + (relVolume * (maxVolume - minVolume)).toInt()
        Log.d(TAG, "volume: $volume")
        audioManager.setStreamVolume(stream, volume, AudioManager.FLAG_SHOW_UI)
    }

    override fun audioVolume(): RelVolume {
        Log.d(TAG, "queryingAudioVolume")
        val audioManager = getSystemService(Service.AUDIO_SERVICE) as AudioManager
        val stream = communicationAudioStream(audioManager)
        Log.d(TAG, "stream: $stream")
        val maxVolume = audioManager.getStreamMaxVolume(stream)
        val minVolume = 1 // audioManager.getStreamMinVolume(stream)
        val volume = audioManager.getStreamVolume(stream)
        Log.d(TAG, "volume: $volume of ($minVolume...$maxVolume)")
        val relVolume = (volume - minVolume).toDouble() / (maxVolume - minVolume)
        Log.d(TAG, "relVolume: $relVolume")
        return relVolume
    }
}

@Suppress("DEPRECATION")
fun currentAudioCommunicationDeviceType(audioManager: AudioManager): Int? {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val deviceType = audioManager.communicationDevice?.type
        return deviceType
    } else {
        if (audioManager.isSpeakerphoneOn) {
            return AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
        }
        if (audioManager.isBluetoothScoOn) {
            return AudioDeviceInfo.TYPE_BLUETOOTH_SCO
        }
        return AudioDeviceInfo.TYPE_UNKNOWN
    }
}

fun communicationAudioStream(audioManager: AudioManager): Int {
    val deviceType = currentAudioCommunicationDeviceType(audioManager)
    val stream = when (deviceType) {
        AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> 6
        else -> AudioManager.STREAM_VOICE_CALL
    }
    return stream
}