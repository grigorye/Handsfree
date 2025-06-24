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
import android.provider.ContactsContract
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.net.toUri
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
    fun invalidatePermissions()
    fun subscribe(observer: ContentObserver)
    fun unsubscribe(observer: ContentObserver)
    fun callLog(): List<CallLogEntry>
    fun accept(visitor: (CallLogEntry) -> Boolean)
}

class CallLogsRepositoryImpl(
    base: Context?
) : ContextWrapper(base), CallLogsRepository {

    private val callUri = "content://call_log/calls".toUri()

    companion object {
        private val TAG = CallLogsRepositoryImpl::class.java.simpleName
    }

    private val delayedObservers = ArrayList<ContentObserver>()

    override fun invalidatePermissions() {
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CALL_LOG
        ) == PackageManager.PERMISSION_GRANTED

        if (hasPermission) {
            for (observer in delayedObservers) {
                subscribeIgnoringPermissions(observer)
            }
            delayedObservers.clear()
        }
    }

    override fun subscribe(observer: ContentObserver) {
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CALL_LOG
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            delayedObservers.add(observer)
            Log.e(TAG, "notPermittedToReadCallLog")
            return
        }
        subscribeIgnoringPermissions(observer)
    }

    private fun subscribeIgnoringPermissions(observer: ContentObserver) {
        contentResolver.registerContentObserver(callUri, true, observer)
    }

    override fun unsubscribe(observer: ContentObserver) {
        delayedObservers.remove(observer)
        contentResolver.unregisterContentObserver(observer)
    }

    private fun cursor(contentResolver: ContentResolver): Cursor? {
        val sortOrder = CallLog.Calls.DATE + " DESC"
        val curCallLogs = contentResolver.query(callUri, null, null, null, sortOrder)

        return curCallLogs
    }

    override fun callLog(): List<CallLogEntry> {
        val entries = ArrayList<CallLogEntry>()
        accept { entry ->
            entries.add(entry)
            true
        }
        return entries
    }

    override fun accept(visitor: (CallLogEntry) -> Boolean) {
        val cursor = cursor(contentResolver) ?: throw AssertionError("callLogs are not accessible")
        while (cursor.moveToNext()) {
            val entry = callLogEntry(this, cursor)
            if (!visitor(entry)) {
                break
            }
        }
        cursor.close()
        return
    }
}

private fun callLogEntry(context: Context, cursor: Cursor): CallLogEntry {
    cursor.apply {
        val numberColumn = getColumnIndex(CallLog.Calls.NUMBER)
        val cachedNameColumn = getColumnIndex(CallLog.Calls.CACHED_NAME)
        val dateColumn = getColumnIndex(CallLog.Calls.DATE)
        val typeColumn = getColumnIndex(CallLog.Calls.TYPE)
        val durationColumn = getColumnIndex(CallLog.Calls.DURATION)
        val isNewColumn = getColumnIndex(CallLog.Calls.NEW)

        val phoneNumber: String? = getString(numberColumn)
        val stringName: String? = getString(cachedNameColumn)
        val name = if (phoneNumber != null && (stringName == "" || stringName == null)) {
            contactName(context, phoneNumber) ?: stringName
        } else {
            stringName
        }
        val date = getLong(dateColumn)
        val type = getInt(typeColumn)
        val duration = getLong(durationColumn)
        val isNew = getInt(isNewColumn)

        return CallLogEntry(phoneNumber ?: "", name, type, date, duration, isNew)
    }
}

private fun contactName(context: Context, phoneNumber: String): String? {
    if (phoneNumber == "") {
        return null
    }
    val hasPermission = ActivityCompat.checkSelfPermission(
        context,
        Manifest.permission.READ_CONTACTS
    ) == PackageManager.PERMISSION_GRANTED
    if (!hasPermission) {
        return null
    }

    val contentResolver = context.contentResolver
    val lookupUri = Uri.withAppendedPath(
        ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
        Uri.encode(phoneNumber)
    )
    val projection = arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME)
    contentResolver.query(lookupUri, projection, null, null, null).use { cursor ->
        if (cursor == null) {
            return null
        }
        if (!cursor.moveToFirst()) {
            return null
        }
        val displayNameColumn = cursor.getColumnIndex(ContactsContract.PhoneLookup.DISPLAY_NAME)
        val displayName: String = cursor.getString(displayNameColumn)
        return displayName
    }
}