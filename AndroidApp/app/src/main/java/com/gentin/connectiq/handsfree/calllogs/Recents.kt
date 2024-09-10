package com.gentin.connectiq.handsfree.calllogs

fun recentsFromCallLog(callLog: List<CallLogEntry>): List<CallLogEntry> {
    return callLog.fold(listOf<CallLogEntry>()) { acc, callLogEntry ->
        if (acc.find { x -> x.number == callLogEntry.number } != null) {
            acc
        } else {
            acc + callLogEntry
        }
    }
}
