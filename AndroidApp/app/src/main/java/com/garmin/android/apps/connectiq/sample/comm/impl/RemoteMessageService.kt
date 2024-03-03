package com.garmin.android.apps.connectiq.sample.comm.impl

interface RemoteMessageService {
    fun sendMessage(message: Map<String, Any>)
}
