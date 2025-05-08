package com.gentin.connectiq.handsfree.helpers

import android.util.Log

fun <T> tracingElapsed(tag: String, label: String, block: () -> T): T {
    val start = System.currentTimeMillis()
    val result = block()
    val end = System.currentTimeMillis()
    Log.d(tag, "Time for $label: ${end - start}ms")
    return result
}
