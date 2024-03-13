package com.gentin.connectiq.handsfree.permissions

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

val manifestPermissions = arrayOf(
    Manifest.permission.ANSWER_PHONE_CALLS,
    Manifest.permission.CALL_PHONE,
    Manifest.permission.FOREGROUND_SERVICE,
    Manifest.permission.FOREGROUND_SERVICE_SPECIAL_USE,
    Manifest.permission.POST_NOTIFICATIONS,
    Manifest.permission.READ_CALL_LOG,
    Manifest.permission.READ_CONTACTS,
    Manifest.permission.READ_PHONE_STATE,
    Manifest.permission.RECEIVE_BOOT_COMPLETED,
    Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
    Manifest.permission.SYSTEM_ALERT_WINDOW
)

val manifestPermissionsHandler = PermissionsHandler(
    hasPermission = { context ->
        manifestPermissions.all {
            ContextCompat.checkSelfPermission(
                context,
                it
            ) == PackageManager.PERMISSION_GRANTED
        }
    },
    requestPermission = { context ->
        ActivityCompat.requestPermissions(context, manifestPermissions, 0)
    }
)
