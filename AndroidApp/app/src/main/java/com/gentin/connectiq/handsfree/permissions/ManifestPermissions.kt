package com.gentin.connectiq.handsfree.permissions

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

val manifestPermissions = arrayOf(
    Manifest.permission.ANSWER_PHONE_CALLS,
    Manifest.permission.CALL_PHONE,
    Manifest.permission.FOREGROUND_SERVICE,
    Manifest.permission.READ_CALL_LOG,
    Manifest.permission.READ_CONTACTS,
    Manifest.permission.READ_PHONE_STATE,
    Manifest.permission.RECEIVE_BOOT_COMPLETED,
    Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
    // SYSTEM_ALERT_WINDOW is checked via Settings.canDrawOverlays()/OverlayPermissionsHandler
    // Manifest.permission.SYSTEM_ALERT_WINDOW,
) + manifestPermissionsExtrasUpsideDownCake() + manifestPermissionsExtrasTiramisu()

fun manifestPermissionsExtrasUpsideDownCake(): Array<String> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        arrayOf(
            Manifest.permission.FOREGROUND_SERVICE_SPECIAL_USE,
        )
    } else {
        arrayOf()
    }
}

fun manifestPermissionsExtrasTiramisu(): Array<String> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        arrayOf(
            Manifest.permission.POST_NOTIFICATIONS,
        )
    } else {
        arrayOf()
    }
}

val manifestPermissionsHandler = PermissionsHandler(
    hasPermission = { context ->
        manifestPermissions.all { permission ->
            val tag = object {}.javaClass.enclosingMethod?.name
            val hasPermission = ContextCompat.checkSelfPermission(
                context,
                permission
            ) == PackageManager.PERMISSION_GRANTED
            Log.d(tag, "$permission: $hasPermission")
            hasPermission
        }
    },
    requestPermission = { context ->
        ActivityCompat.requestPermissions(context, manifestPermissions, 0)
    }
)
