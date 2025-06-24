package com.gentin.connectiq.handsfree.calllogs

fun recentsFromCallLog(callLogsRepository: CallLogsRepository): List<CallLogEntry> {
    val callLog = callLogsRepository.callLog()
    return callLog.fold(listOf()) { acc, callLogEntry ->
        if (acc.find { x -> x.number == callLogEntry.number } != null) {
            acc
        } else {
            acc + callLogEntry
        }
    }
}
