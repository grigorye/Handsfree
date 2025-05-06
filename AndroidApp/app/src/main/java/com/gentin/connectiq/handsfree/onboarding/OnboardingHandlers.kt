package com.gentin.connectiq.handsfree.onboarding

import android.content.Context
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
    val message = if (isInEmulatorMode(context))
        "Emulator mode is on"
    else
        "Emulator mode is off"
    snackbar(fragment, message)
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