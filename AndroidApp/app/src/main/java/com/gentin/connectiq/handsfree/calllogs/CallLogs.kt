package com.gentin.connectiq.handsfree.calllogs

import android.content.ContentResolver
import android.content.Context
import android.content.ContextWrapper
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.provider.CallLog

data class CallLogEntry(
    val number: String,
    val name: String?,
    val type: Int,
    val date: Long,
    val duration: Long,
    val isNew: Int
)

interface CallLogsRepository {
    fun subscribe(observer: ContentObserver)
    fun unsubscribe(observer: ContentObserver)
    fun callLog(): List<CallLogEntry>
}

class CallLogsRepositoryImpl(
    base: Context?
) : ContextWrapper(base), CallLogsRepository {

    private val callUri = Uri.parse("content://call_log/calls")

    override fun subscribe(observer: ContentObserver) {
        contentResolver.registerContentObserver(callUri, true, observer)
    }

    override fun unsubscribe(observer: ContentObserver) {
        contentResolver.unregisterContentObserver(observer)
    }

    private fun cursor(contentResolver: ContentResolver): Cursor? {
        val sortOrder = CallLog.Calls.DATE
        val curCallLogs = contentResolver.query(callUri, null, null, null, sortOrder)

        return curCallLogs
    }

    override fun callLog(): List<CallLogEntry> {
        val cursor = cursor(contentResolver) ?: throw AssertionError("callLogs are not accessible")
        val entries = ArrayList<CallLogEntry>()
        while (cursor.moveToNext()) {
            val entry = callLogEntry(cursor)
            entries.add(entry)
        }
        cursor.close()
        return entries.reversed()
    }
}

private fun callLogEntry(cursor: Cursor): CallLogEntry {
    cursor.apply {
        val numberColumn = getColumnIndex(CallLog.Calls.NUMBER)
        val cachedNameColumn = getColumnIndex(CallLog.Calls.CACHED_NAME)
        val dateColumn = getColumnIndex(CallLog.Calls.DATE)
        val typeColumn = getColumnIndex(CallLog.Calls.TYPE)
        val durationColumn = getColumnIndex(CallLog.Calls.DURATION)
        val isNewColumn = getColumnIndex(CallLog.Calls.NEW)

        val phoneNumber = getString(numberColumn)
        val name = getString(cachedNameColumn)
        val date = getLong(dateColumn)
        val type = getInt(typeColumn)
        val duration = getLong(durationColumn)
        val isNew = getInt(isNewColumn)

        return CallLogEntry(phoneNumber, name, type, date, duration, isNew)
    }
}
