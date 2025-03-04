package com.gentin.connectiq.handsfree.permissions

import android.annotation.SuppressLint
import android.content.Context.POWER_SERVICE
import android.content.Intent
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.core.net.toUri

@SuppressLint("BatteryLife")
val batteryOptimizationPermissionHandler = newAllRequiredPermissionHandler(
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
        intent.setData("package:${context.packageName}".toUri())
        context.startActivity(intent)
    }
)
