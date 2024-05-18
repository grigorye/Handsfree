package com.gentin.connectiq.handsfree.impl

import android.text.TextUtils
import com.gentin.connectiq.handsfree.services.startStats

fun statusInfo(): String {
    return TextUtils.join(
        ", ", arrayOf(
            "i.${startStats.incomingMessage}",
            "p.${startStats.phoneState}",
            "e.${sdkRelaunchesOnExceptions}",
            "o.${startStats.other}",
            "b.${startStats.bootCompleted}",
            "m.${startStats.mainActivity}"
        )
    )
}