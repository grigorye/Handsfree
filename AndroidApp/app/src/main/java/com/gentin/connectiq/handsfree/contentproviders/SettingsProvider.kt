package com.gentin.connectiq.handsfree.contentproviders

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.content.SharedPreferences
import android.content.UriMatcher
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import androidx.preference.PreferenceManager

class SettingsProvider : ContentProvider() {

    companion object {
        private const val AUTHORITY = "com.gentin.connectiq.handsfree.contentproviders.SettingsProvider"
        private const val PREFS_KEY = "key"
        private const val PREFS_VALUE = "value"
        private const val PREFS = 1

        private val uriMatcher = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, "prefs", PREFS)
        }
    }

    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate(): Boolean {
        context?.let {
            sharedPreferences = PreferenceManager.getDefaultSharedPreferences(it)
        }
        return true
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? {
        when (uriMatcher.match(uri)) {
            PREFS -> {
                values?.let {
                    val key = it.getAsString(PREFS_KEY)
                    val value = it.get(PREFS_VALUE)
                    val editor = sharedPreferences.edit()
                    if (value == null) {
                        throw IllegalArgumentException("Value cannot be null")
                    }
                    when (value) {
                        is String -> editor.putString(key, value)
                        is Boolean -> editor.putBoolean(key, value)
                        else -> throw IllegalArgumentException("Unsupported value type: ${value.javaClass}")
                    }
                    editor.apply()
                    context?.contentResolver?.notifyChange(uri, null)
                }
                return uri
            }

            else -> throw IllegalArgumentException("Unsupported URI: $uri")
        }
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? {
        when (uriMatcher.match(uri)) {
            PREFS -> {
                val cursor = MatrixCursor(arrayOf(PREFS_KEY, PREFS_VALUE))
                sharedPreferences.all.forEach { (key, value) ->
                    cursor.addRow(arrayOf(key, value))
                }
                return cursor
            }

            else -> throw IllegalArgumentException("Unsupported URI: $uri")
        }
    }

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?
    ): Int {
        when (uriMatcher.match(uri)) {
            PREFS -> {
                var updatedRows = 0
                values?.let {
                    val key = it.getAsString(PREFS_KEY)
                    if (sharedPreferences.contains(key)) {
                        val value = it.getAsString(PREFS_VALUE)
                        sharedPreferences.edit().putString(key, value).apply()
                        updatedRows = 1
                        context?.contentResolver?.notifyChange(uri, null)
                    }
                }
                return updatedRows
            }

            else -> throw IllegalArgumentException("Unsupported URI: $uri")
        }
    }

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int {
        when (uriMatcher.match(uri)) {
            PREFS -> {
                var deletedRows = 0
                selectionArgs?.let {
                    it.forEach { key ->
                        if (sharedPreferences.contains(key)) {
                            sharedPreferences.edit().remove(key).apply()
                            deletedRows++
                        }
                    }
                }
                if (deletedRows > 0) {
                    context?.contentResolver?.notifyChange(uri, null)
                }
                return deletedRows
            }

            else -> throw IllegalArgumentException("Unsupported URI: $uri")
        }
    }

    override fun getType(uri: Uri): String? {
        return when (uriMatcher.match(uri)) {
            PREFS -> "vnd.android.cursor.dir/vnd.$AUTHORITY.prefs"
            else -> throw IllegalArgumentException("Unsupported URI: $uri")
        }
    }
}