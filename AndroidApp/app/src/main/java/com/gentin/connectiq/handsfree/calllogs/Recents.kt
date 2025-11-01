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
