package com.gentin.connectiq.handsfree.helpers

import android.os.Build

fun isRunningInEmulator(): Boolean {
    if (Build.DEVICE == "emu64a" || Build.DEVICE == "emu64xa") {
        return true
    }
    return false
}