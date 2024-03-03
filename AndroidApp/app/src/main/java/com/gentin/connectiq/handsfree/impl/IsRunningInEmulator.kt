package com.gentin.connectiq.handsfree.impl

import android.os.Build

fun isRunningInEmulator(): Boolean {
    return Build.DEVICE == "emu64a"
}