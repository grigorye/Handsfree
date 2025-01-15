package com.gentin.connectiq.handsfree.activities

import android.content.Context
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.startConnector

fun invalidatePermissions(context: Context, permissions: Array<String>, grantResults: IntArray) {
    startConnector(context, ACTIVATE_AND_RECONNECT)
}

fun invalidateSubjects(context: Context) {
    startConnector(context, ACTIVATE_AND_RECONNECT)
}