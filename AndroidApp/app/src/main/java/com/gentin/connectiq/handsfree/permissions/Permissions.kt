package com.gentin.connectiq.handsfree.permissions

import android.app.Activity

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
            it.requestPermission(context)
        }
    }
}
