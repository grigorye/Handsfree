package com.gentin.connectiq.handsfree.helpers

fun breakIntoDebugger() {
    if (debugEnabled) {
        android.os.Debug.waitForDebugger()
        println("")
    }
}

private var debugEnabled = false
