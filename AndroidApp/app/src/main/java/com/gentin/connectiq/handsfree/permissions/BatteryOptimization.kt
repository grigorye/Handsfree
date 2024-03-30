package com.gentin.connectiq.handsfree.permissions

import android.annotation.SuppressLint
import android.content.Context.POWER_SERVICE
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.util.Log

@SuppressLint("BatteryLife")
val batteryOptimizationPermissionsHandler = PermissionsHandler(
    hasPermission = { context ->
        val tag = object {}.javaClass.enclosingMethod?.name

        val packageName = context.packageName
        val pm = context.getSystemService(POWER_SERVICE) as PowerManager
        val isIgnoringBatteryOptimizations = pm.isIgnoringBatteryOptimizations(packageName)
        Log.d(tag, "isIgnoringBatteryOptimizations: $isIgnoringBatteryOptimizations")
        isIgnoringBatteryOptimizations
    },
    requestPermission = { context ->
        val intent = Intent()
        intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
        intent.setData(Uri.parse("package:${context.packageName}"))
        context.startActivity(intent)
    }
)
