package com.gentin.connectiq.handsfree.helpers

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.FileReader
import java.io.FileWriter
import java.io.InputStreamReader
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

const val REQUEST_CODE_SHARE_LOG = 123

fun saveLog(context: Context, uri: Uri) {
    val path = "/sdcard/Download/Handsfree.log"
    val process = Runtime.getRuntime().exec("logcat -d -f $path")
    process.waitFor()

    context.contentResolver.openFileDescriptor(uri, "w")?.use { closeable ->
        val bufferedWriter = BufferedWriter(FileWriter(closeable.fileDescriptor))
        val bufferedReader = BufferedReader(FileReader(path))
        var oneLine: String?
        while ((bufferedReader.readLine().also { oneLine = it }) != null) {
            bufferedWriter.write(oneLine)
            bufferedWriter.newLine()
        }
        bufferedWriter.flush()
    }
}

fun shareLog(activity: Activity) {
    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "text/plain"
        val timestamp = SimpleDateFormat("YYYYMMdd-HHmm", Locale.US).format(Date())
        putExtra(Intent.EXTRA_TITLE, "HF_$timestamp")
    }
    activity.startActivityForResult(intent, REQUEST_CODE_SHARE_LOG)
}