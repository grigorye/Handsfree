package com.gentin.connectiq.handsfree.permissions

import android.app.Activity
import android.view.View

enum class PermissionStatus {
    Granted,
    NotGranted,
    Denied
}

data class PermissionsHandler(
    val permissionStatus: (context: Activity) -> PermissionStatus,
    val requestPermission: (context: Activity, contextView: View?) -> Unit
) {
    fun hasPermission(context: Activity): Boolean {
        return permissionStatus(context) == PermissionStatus.Granted
    }
}
