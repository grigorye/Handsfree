package com.gentin.connectiq.handsfree.helpers

import android.content.Context
import android.os.Build
import com.gentin.connectiq.handsfree.globals.isInEmulatorMode

fun isRunningInEmulator(context: Context): Boolean {
    if (isInEmulatorMode(context)) {
        return true
    }
    return Build.DEVICE == "emu64a" || Build.DEVICE == "emu64xa"
}