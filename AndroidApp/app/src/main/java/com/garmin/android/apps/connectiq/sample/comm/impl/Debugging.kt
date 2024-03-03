package com.garmin.android.apps.connectiq.sample.comm.impl

fun breakIntoDebugger() {
    if (debugEnabled) {
        android.os.Debug.waitForDebugger()
        println("")
    }
}

private var debugEnabled = false
