package com.gentin.connectiq.handsfree.permissions

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

val registeredPermissionHandlers = arrayOf(
    manifestPermissionsHandler,
    batteryOptimizationPermissionsHandler,
    overlayPermissionsHandler
)

fun anyPermissionMissing(context: Activity): Boolean {
    return registeredPermissionHandlers.any { !it.hasPermission(context) }
}

fun requestPermissions(context: Activity) {
    registeredPermissionHandlers.forEach {
        if (!it.hasPermission(context)) {
            it.requestPermission(context, null)
        }
    }
}

fun openAppSettings(context: Context) {
    context.apply {
        startActivity(Intent().apply {
            action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
            data = Uri.fromParts("package", packageName, null)
        })
    }
}

