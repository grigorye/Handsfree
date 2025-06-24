package com.gentin.connectiq.handsfree.calllogs

fun recentsFromCallLog(callLogsRepository: CallLogsRepository, limit: Int): List<CallLogEntry> {
    val acc: MutableList<CallLogEntry> = mutableListOf()
    callLogsRepository.accept { callLogEntry ->
        if (acc.find { x -> x.number == callLogEntry.number } != null) {
            return@accept true
        }
        acc += callLogEntry
        return@accept acc.size <= limit
    }
    return acc
}

fun recentsFromCallLogV1(callLogsRepository: CallLogsRepository, limit: Int): List<CallLogEntry> {
    val callLog = callLogsRepository.callLog()
    val recents: List<CallLogEntry> = callLog.fold(listOf()) { acc, callLogEntry ->
        if (acc.find { x -> x.number == callLogEntry.number } != null) {
            acc
        } else {
            acc + callLogEntry
        }
    }
    return recents.take(limit)
}