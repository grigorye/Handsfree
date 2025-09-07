package com.gentin.connectiq.handsfree.helpers

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.gentin.connectiq.handsfree.impl.versionInfo
import com.gentin.connectiq.handsfree.services.g
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

const val REQUEST_CODE_SHARE_LOG = 123

fun saveLog(context: Context, uri: Uri) {
    try {
        val process = Runtime.getRuntime().exec("logcat -d")
        val reader = BufferedReader(InputStreamReader(process.inputStream))

        val outputStream = context.contentResolver.openOutputStream(uri) ?: return
        val writer = BufferedWriter(OutputStreamWriter(outputStream))

        var line: String?
        while (reader.readLine().also { line = it } != null) {
            writer.write(line + "\n")
        }

        writer.close()
        reader.close()
    } catch (e: Exception) {
        e.printStackTrace()
    }
}

fun shareLog(activity: Activity) {
    val tag = object {}.javaClass.enclosingMethod?.name
    Log.d(tag, "${versionInfo()}")
    Log.d(tag, "startStats: $g.startStats")
    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "text/plain"
        val timestamp = SimpleDateFormat("yyyyMMdd-HHmm", Locale.US).format(Date())
        putExtra(Intent.EXTRA_TITLE, "HF_$timestamp")
    }
    activity.startActivityForResult(intent, REQUEST_CODE_SHARE_LOG)
}