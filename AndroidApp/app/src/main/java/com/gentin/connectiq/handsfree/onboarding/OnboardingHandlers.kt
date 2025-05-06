package com.gentin.connectiq.handsfree.onboarding

import android.content.Context
import android.content.Intent
import androidx.fragment.app.Fragment
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.isInDebugMode
import com.gentin.connectiq.handsfree.globals.isInEmulatorMode
import com.gentin.connectiq.handsfree.globals.setIsInDebugMode
import com.gentin.connectiq.handsfree.globals.setIsInEmulatorMode
import com.google.android.material.snackbar.Snackbar

fun toggleDebugMode(context: Context, fragment: Fragment) {
    setIsInDebugMode(context, !isInDebugMode(context))
    val message = if (isInDebugMode(context))
        "Debug mode is on"
    else
        "Debug mode is off"
    snackbar(fragment, message)
}

fun toggleEmulatorMode(context: Context, fragment: Fragment) {
    setIsInEmulatorMode(context, !isInEmulatorMode(context))
    restartApp(context)
}

fun restartApp(context: Context) {
    val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    intent?.apply {
        addFlags(
            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TASK)
        context.startActivity(this)
        Runtime.getRuntime().exit(0) // Optional: forcefully terminates the current process
    }
}

fun snackbar(fragment: Fragment, message: String) {
    val contextView = fragment.view
    contextView?.apply {
        Snackbar
            .make(
                this,
                message,
                Snackbar.LENGTH_SHORT
            )
            .setAnchorView(R.id.nav_bar_view)
            .show()
    }
}