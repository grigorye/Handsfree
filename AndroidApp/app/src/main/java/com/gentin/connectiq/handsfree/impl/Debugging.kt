package com.gentin.connectiq.handsfree.impl

fun breakIntoDebugger() {
    if (debugEnabled) {
        android.os.Debug.waitForDebugger()
        println("")
    }
}

private var debugEnabled = false
