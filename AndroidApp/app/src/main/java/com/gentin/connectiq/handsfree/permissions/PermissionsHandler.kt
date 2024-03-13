package com.gentin.connectiq.handsfree.permissions

import android.app.Activity

data class PermissionsHandler(
    val hasPermission: (context: Activity) -> Boolean,
    val requestPermission: (context: Activity) -> Unit
)
