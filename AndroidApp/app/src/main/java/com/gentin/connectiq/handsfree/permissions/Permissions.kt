package com.gentin.connectiq.handsfree.permissions

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

fun openAppSettings(context: Context) {
    openSettings(context, context.packageName)
}

fun openGarminConnectSettings(context: Context) {
    openSettings(context, "com.garmin.android.apps.connectmobile")
}

fun openSettings(context: Context, packageName: String) {
    context.apply {
        startActivity(Intent().apply {
            action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
            data = Uri.fromParts("package", packageName, null)
        })
    }
}
