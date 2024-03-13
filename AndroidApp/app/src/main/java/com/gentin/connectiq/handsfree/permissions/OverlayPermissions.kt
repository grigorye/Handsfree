package com.gentin.connectiq.handsfree.permissions

import android.content.Intent
import android.net.Uri
import android.provider.Settings

val overlayPermissionsHandler = PermissionsHandler(
    hasPermission = { context ->
        Settings.canDrawOverlays(context)
    },
    requestPermission = { context ->
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}")
        )
        context.startActivityForResult(intent, -1)
    }
)