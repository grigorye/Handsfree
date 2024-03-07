package com.gentin.connectiq.handsfree.helpers

import android.os.Build

fun isRunningInEmulator(): Boolean {
    return Build.DEVICE == "emu64a"
}