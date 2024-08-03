package com.gentin.connectiq.handsfree.fragments

import android.os.Bundle
import androidx.preference.PreferenceFragmentCompat

class DynamicSettingsFragment(
    private val onCreatePreferencesImp: ((PreferenceFragmentCompat) -> Unit)? = null
) : PreferenceFragmentCompat() {
    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        onCreatePreferencesImp?.invoke(this)
    }
}