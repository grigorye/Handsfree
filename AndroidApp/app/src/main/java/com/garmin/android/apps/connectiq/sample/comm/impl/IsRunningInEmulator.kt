package com.garmin.android.apps.connectiq.sample.comm.impl

import android.os.Build

fun isRunningInEmulator(): Boolean {
    return Build.DEVICE == "emu64a"
}