package com.gentin.connectiq.handsfree.permissions

import android.app.Activity
import android.content.Context

enum class PermissionStatus {
    Granted,
    NotGranted,
    NotGrantedNeedsRationale
}

data class PermissionHandler(
    var isPermissionRequested: (context: Context) -> Boolean,
    val hasPermission: (context: Context) -> Boolean,
    val hasRequiredPermission: (context: Context) -> Boolean,
    val permissionStatus: (context: Activity) -> PermissionStatus,
    val requestPermission: (activity: Activity) -> Unit
)

fun newAllRequiredPermissionHandler(
    hasPermission: (context: Context) -> Boolean,
    requestPermission: (activity: Activity) -> Unit
): PermissionHandler {
    return PermissionHandler(
        isPermissionRequested = {
            true
        },
        hasPermission = { context ->
            hasPermission(context)
        },
        hasRequiredPermission = { context ->
            hasPermission(context)
        },
        permissionStatus = { context ->
            if (hasPermission(context)) {
                PermissionStatus.Granted
            } else {
                PermissionStatus.NotGranted
            }
        },
        requestPermission = { activity ->
            requestPermission(activity)
        }
    )
}

