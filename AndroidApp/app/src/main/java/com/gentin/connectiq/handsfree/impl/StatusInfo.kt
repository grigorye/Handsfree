package com.gentin.connectiq.handsfree.impl

import android.text.TextUtils
import com.gentin.connectiq.handsfree.services.g

fun statusInfo(): String {
    return TextUtils.join(
        ", ", arrayOf(
            "i.${g.startStats.incomingMessage}",
            "p.${g.startStats.phoneState}",
            "e.${g.startStats.sdkExceptionDates.count()}",
            "o.${g.startStats.other}",
            "b.${g.startStats.bootCompleted}",
            "m.${g.startStats.mainActivity}"
        )
    )
}