package com.gentin.connectiq.handsfree.globals

import android.content.Context
import androidx.preference.PreferenceManager

fun essentialsAreOn(context: Context): Boolean {
    val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
    return sharedPreferences.getBoolean("essentials", false)
}

fun outgoingCallsShouldBeEnabled(context: Context): Boolean {
    val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
    return sharedPreferences.getBoolean(
        "essentials",
        false
    ) && sharedPreferences.getBoolean("outgoing_calls", false)
}

fun callInfoShouldBeEnabled(context: Context): Boolean {
    val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
    return sharedPreferences.getBoolean("full_featured", false)
}

fun isInDebugMode(context: Context): Boolean {
    val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
    return sharedPreferences.getBoolean("debug", false)
}

fun setIsInDebugMode(context: Context, value: Boolean) {
    val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
    with(sharedPreferences.edit()) {
        putBoolean("debug", value)
        apply()
    }
}