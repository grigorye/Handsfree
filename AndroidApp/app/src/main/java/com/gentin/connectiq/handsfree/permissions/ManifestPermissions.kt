package com.gentin.connectiq.handsfree.permissions

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

val manifestPermissions = listOf(
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

fun manifestPermissionsExtrasUpsideDownCake(): List<String> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        listOf(
            Manifest.permission.FOREGROUND_SERVICE_SPECIAL_USE,
        )
    } else {
        listOf()
    }
}

fun manifestPermissionsExtrasTiramisu(): List<String> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        listOf(
            Manifest.permission.POST_NOTIFICATIONS,
        )
    } else {
        listOf()
    }
}

val manifestPermissionsHandler = newManifestPermissionsHandler(manifestPermissions)

fun newManifestPermissionsHandler(manifestPermissions: List<String>): PermissionsHandler {
    return PermissionsHandler(
        permissionStatus = { context ->
            var allPermissionsGranted = true
            var anyPermissionDenied = false
            for (permission in manifestPermissions) {
                val tag = object {}.javaClass.enclosingMethod?.name
                val hasPermission = ContextCompat.checkSelfPermission(
                    context,
                    permission
                ) == PackageManager.PERMISSION_GRANTED
                Log.d(tag, "$permission: $hasPermission")
                if (!hasPermission) {
                    val shouldShowRequestPermissionsRationale =
                        ActivityCompat.shouldShowRequestPermissionRationale(context, permission)
                    Log.d(
                        tag,
                        "$permission.shouldShowRequestPermissionsRationale: $shouldShowRequestPermissionsRationale"
                    )
                    if (!shouldShowRequestPermissionsRationale) {
                        anyPermissionDenied = true
                    }
                    allPermissionsGranted = false
                }
            }

            if (allPermissionsGranted) {
                PermissionStatus.Granted
            } else if (anyPermissionDenied) {
                PermissionStatus.Denied
            } else {
                PermissionStatus.NotGranted
            }
        },
        requestPermission = { context ->
            ActivityCompat.requestPermissions(context, manifestPermissions.toTypedArray(), 0)
        }
    )
}
