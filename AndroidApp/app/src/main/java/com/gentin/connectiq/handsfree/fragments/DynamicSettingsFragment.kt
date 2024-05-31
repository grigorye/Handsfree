package com.gentin.connectiq.handsfree.fragments

import android.os.Bundle
import androidx.preference.PreferenceFragmentCompat

class DynamicSettingsFragment(val onCreatePreferencesImp: (PreferenceFragmentCompat) -> Unit) : PreferenceFragmentCompat() {
    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        onCreatePreferencesImp(this)
    }
}