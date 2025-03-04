package com.gentin.connectiq.handsfree.permissions

import android.content.Intent
import android.provider.Settings
import android.util.Log
import androidx.core.net.toUri

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
            "package:${context.packageName}".toUri()
        )
        context.startActivityForResult(intent, -1)
    }
)
