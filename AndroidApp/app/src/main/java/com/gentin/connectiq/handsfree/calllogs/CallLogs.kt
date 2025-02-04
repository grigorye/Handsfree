package com.gentin.connectiq.handsfree.calllogs

import android.Manifest
import android.content.ContentResolver
import android.content.Context
import android.content.ContextWrapper
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.provider.CallLog
import android.util.Log
import androidx.core.app.ActivityCompat
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CallLogEntry(
    @SerialName("n") val number: String,
    @SerialName("m") val name: String?,
    @SerialName("t") val type: Int,
    @SerialName("d") val date: Long,
    @SerialName("r") val duration: Long,
    @SerialName("w") val isNew: Int
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

    companion object {
        private val TAG = CallLogsRepositoryImpl::class.java.simpleName
    }

    override fun subscribe(observer: ContentObserver) {
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CALL_LOG
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            Log.e(TAG, "notPermittedToReadCallLog")
            return
        }
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
        val stringName = getString(cachedNameColumn)
        val name = if (stringName == "") { null } else { stringName }
        val date = getLong(dateColumn)
        val type = getInt(typeColumn)
        val duration = getLong(durationColumn)
        val isNew = getInt(isNewColumn)

        return CallLogEntry(phoneNumber, name, type, date, duration, isNew)
    }
}
