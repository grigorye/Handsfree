package com.gentin.connectiq.handsfree.globals

import com.gentin.connectiq.handsfree.impl.isRunningInEmulator
import com.garmin.android.connectiq.IQApp

val COMM_WATCH_ID = if (isRunningInEmulator()) {
    ""
} else {
    "a3d8da80-e013-41f9-aca4-f66bb38fad3f"
}
val myApp = IQApp(COMM_WATCH_ID)