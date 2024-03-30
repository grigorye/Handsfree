package com.gentin.connectiq.handsfree.permissions

import android.app.Activity

enum class PermissionStatus {
    Granted,
    NotGranted,
    Denied
}

data class PermissionsHandler(
    val permissionStatus: (context: Activity) -> PermissionStatus,
    val requestPermission: (context: Activity) -> Unit
) {
    fun hasPermission(context: Activity): Boolean {
        return permissionStatus(context) == PermissionStatus.Granted
    }
}
