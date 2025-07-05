package com.gentin.connectiq.handsfree.permissions

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

fun isPermissionRequested(context: Context, permission: String): Boolean {
    val info = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS)
    return info.requestedPermissions?.contains(permission) == true
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
