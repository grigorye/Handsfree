package com.gentin.connectiq.handsfree.calllogs

private const val maxRecentsCount = 10

fun recentsFromCallLog(callLog: List<CallLogEntry>): List<CallLogEntry> {
    return callLog.fold(listOf<CallLogEntry>()) { acc, callLogEntry ->
        if (acc.find { x -> x.number == callLogEntry.number } != null) {
            acc
        } else {
            acc + callLogEntry
        }
    }.take(maxRecentsCount)
}
