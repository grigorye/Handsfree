package com.gentin.connectiq.handsfree.permissions

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.util.Log

val overlayPermissionHandler = PermissionHandler(
    permissionStatus = { context ->
        val tag = object {}.javaClass.enclosingMethod?.name
        val canDrawOverlays = Settings.canDrawOverlays(context)
        Log.d(tag, "canDrawOverlays: $canDrawOverlays")
        if (canDrawOverlays) {
            PermissionStatus.Granted
        } else {
            PermissionStatus.NotGranted
        }
    },
    requestPermission = { context ->
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}")
        )
        context.startActivityForResult(intent, -1)
    }
)