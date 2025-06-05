package com.gentin.connectiq.handsfree.permissions

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

private val baseManifestPermissions = listOf(
    Manifest.permission.ANSWER_PHONE_CALLS,
    Manifest.permission.CALL_PHONE,
    Manifest.permission.FOREGROUND_SERVICE,
    Manifest.permission.READ_CONTACTS,
    Manifest.permission.READ_PHONE_STATE,
    Manifest.permission.RECEIVE_BOOT_COMPLETED,
    Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
    // SYSTEM_ALERT_WINDOW is checked via Settings.canDrawOverlays()/OverlayPermissionHandler
    // Manifest.permission.SYSTEM_ALERT_WINDOW,
)

private fun manifestPermissions(context: Context): List<String> {
    return baseManifestPermissions + manifestPermissionsRejectedByGooglePlay(context) + manifestPermissionsExtrasUpsideDownCake() + manifestPermissionsExtrasTiramisu()
}

fun isPermissionRequested(context: Context, permission: String): Boolean {
    val info = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS)
    return info.requestedPermissions?.contains(permission) == true
}

fun manifestPermissionsRejectedByGooglePlay(context: Context): List<String> {
    return if (isPermissionRequested(context, Manifest.permission.READ_CALL_LOG)) {
        listOf(
            Manifest.permission.READ_CALL_LOG,
        )
    } else {
        listOf()
    }
}

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

fun newManifestPermissionHandler(context: Context): PermissionHandler {
    return newManifestPermissionHandler(
        requiredPermissions = manifestPermissions(context),
        optionalPermissions = listOf()
    )
}

fun hasPermissions(context: Context, permissions: List<String>): Boolean {
    val allGranted = permissions.all { permission ->
        val tag = object {}.javaClass.enclosingMethod?.name
        val hasPermission = ContextCompat.checkSelfPermission(
            context,
            permission
        ) == PackageManager.PERMISSION_GRANTED
        Log.d(tag, "$permission: $hasPermission")
        hasPermission
    }
    return allGranted
}

fun newManifestPermissionHandler(requiredPermissions: List<String>, optionalPermissions: List<String>): PermissionHandler {
    return PermissionHandler(
        isPermissionRequested = { context ->
            for (permission in requiredPermissions + optionalPermissions) {
                if (!isPermissionRequested(context, permission)) {
                    return@PermissionHandler false
                }
            }
            true
        },
        hasPermission = { context ->
            hasPermissions(context, requiredPermissions + optionalPermissions)
        },
        hasRequiredPermission = { context ->
            hasPermissions(context, requiredPermissions)
        },
        permissionStatus = { context ->
            var allPermissionsGranted = true
            var anyPermissionNeedsRationale = false
            val allPermissions = requiredPermissions + optionalPermissions
            for (permission in allPermissions) {
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
                    if (shouldShowRequestPermissionsRationale) {
                        anyPermissionNeedsRationale = true
                    }
                    allPermissionsGranted = false
                }
            }

            if (allPermissionsGranted) {
                PermissionStatus.Granted
            } else if (anyPermissionNeedsRationale) {
                PermissionStatus.NotGrantedNeedsRationale
            } else {
                PermissionStatus.NotGranted
            }
        },
        requestPermission = { context ->
            val allPermissions = requiredPermissions + optionalPermissions
            ActivityCompat.requestPermissions(context, allPermissions.toTypedArray(), 0)
        }
    )
}
