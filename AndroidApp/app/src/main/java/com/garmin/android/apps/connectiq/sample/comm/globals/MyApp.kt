package com.garmin.android.apps.connectiq.sample.comm.globals

import com.garmin.android.apps.connectiq.sample.comm.impl.isRunningInEmulator
import com.garmin.android.connectiq.IQApp

val COMM_WATCH_ID = if (isRunningInEmulator()) {
    ""
} else {
    "a3421feed289106a538cb9547ab12095"
}
val myApp = IQApp(COMM_WATCH_ID)
