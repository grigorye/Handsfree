package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.content.Context.POWER_SERVICE
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.util.Log

fun requestIgnoreBatteryOptimizations(context: Context) {
    val tag = object {}.javaClass.enclosingMethod?.name

    val packageName = context.packageName
    val pm = context.getSystemService(POWER_SERVICE) as PowerManager
    val isIgnoringBatteryOptimizations = pm.isIgnoringBatteryOptimizations(packageName)
    Log.i(tag, "isIgnoringBatteryOptimizations: $isIgnoringBatteryOptimizations")
    if (!isIgnoringBatteryOptimizations) {
        val intent = Intent()
        intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
        intent.setData(Uri.parse("package:$packageName"))
        context.startActivity(intent)
    }
}