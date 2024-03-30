package com.gentin.connectiq.handsfree.permissions

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context.POWER_SERVICE
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.view.View
import com.gentin.connectiq.handsfree.R
import com.google.android.material.snackbar.Snackbar

@SuppressLint("BatteryLife")
val batteryOptimizationPermissionsHandler = PermissionsHandler(
    permissionStatus = { context ->
        batteryOptimizationPermissionStatus(context)
    },
    requestPermission = { context, contextView ->
        requestBatteryOptimizationPermission(context, contextView)
    }
)

private fun batteryOptimizationPermissionStatus(context: Activity): PermissionStatus {
    val tag = object {}.javaClass.enclosingMethod?.name

    val packageName = context.packageName
    val pm = context.getSystemService(POWER_SERVICE) as PowerManager
    val isIgnoringBatteryOptimizations = pm.isIgnoringBatteryOptimizations(packageName)
    Log.d(tag, "isIgnoringBatteryOptimizations: $isIgnoringBatteryOptimizations")
    return if (isIgnoringBatteryOptimizations) {
        PermissionStatus.Granted
    } else {
        PermissionStatus.NotGranted
    }
}

private fun requestBatteryOptimizationPermission(context: Activity, contextView: View?) {
    when (batteryOptimizationPermissionStatus(context)) {
        PermissionStatus.NotGranted -> {
            val intent = Intent()
            intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.setData(Uri.parse("package:${context.packageName}"))
            context.startActivity(intent)
        }

        PermissionStatus.Granted -> {
            contextView?.apply {
                Snackbar
                    .make(
                        this,
                        R.string.permissions_snackbar_permission_is_already_granted,
                        Snackbar.LENGTH_SHORT
                    )
                    .setAction(R.string.permissions_snackbar_app_settings_btn) {
                        openAppSettings(context)
                    }
                    .show()
            }
        }

        PermissionStatus.Denied -> {
            contextView?.apply {
                Snackbar
                    .make(
                        this,
                        R.string.permissions_snackbar_permission_is_denied,
                        Snackbar.LENGTH_SHORT
                    )
                    .setAction(R.string.permissions_snackbar_app_settings_btn) {
                        openAppSettings(context)
                    }
                    .show()
            }
        }
    }
}