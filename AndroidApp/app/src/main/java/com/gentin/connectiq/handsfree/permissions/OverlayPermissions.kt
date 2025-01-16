package com.gentin.connectiq.handsfree.permissions

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.util.Log

val overlayPermissionHandler = newAllRequiredPermissionHandler(
    hasPermission = { context ->
        val tag = object {}.javaClass.enclosingMethod?.name
        val canDrawOverlays = Settings.canDrawOverlays(context)
        Log.d(tag, "canDrawOverlays: $canDrawOverlays")
        canDrawOverlays
    },
    requestPermission = { context ->
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}")
        )
        context.startActivityForResult(intent, -1)
    }
)
