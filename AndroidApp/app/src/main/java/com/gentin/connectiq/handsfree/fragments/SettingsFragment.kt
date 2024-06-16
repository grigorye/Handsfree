package com.gentin.connectiq.handsfree.fragments

import android.Manifest
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.DefaultServiceLocator
import com.gentin.connectiq.handsfree.impl.DeviceInfo
import com.gentin.connectiq.handsfree.onboarding.resolveLink
import com.gentin.connectiq.handsfree.permissions.isPermissionRequested

class SettingsFragment(private val preferencesResId: Int = R.xml.root_preferences) :
    PreferenceFragmentCompat() {

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        assert(rootKey == null)
    }

    override fun onResume() {
        super.onResume()

        preferenceScreen = null
        setupPreferences()
    }

    private fun setupPreferences() {
        setPreferencesFromResource(preferencesResId, null)
        setupDevicesPreference()
        setupPermissionPreference(
            essentialsPreference,
            R.string.settings_essentials,
            R.string.settings_essentials_on,
            R.string.settings_essentials_off
        )
        setupPermissionPreference(
            outgoingCallsPreference,
            R.string.settings_outgoing_calls,
            R.string.settings_outgoing_calls_on,
            R.string.settings_outgoing_calls_off,
            R.string.settings_disabled_due_to_essentials_are_off
        )
        setupPermissionPreference(
            callInfoPreference,
            R.string.settings_call_info,
            R.string.settings_call_info_on,
            R.string.settings_call_info_off,
            R.string.settings_disabled_due_to_essentials_are_off
        )
        callInfoPreference?.isVisible =
            isPermissionRequested(requireActivity(), Manifest.permission.READ_CALL_LOG)
        setupContactsPreference()
    }

    private fun setupDevicesPreference(
        knownDeviceInfos: LiveData<List<DeviceInfo>> = DefaultServiceLocator.knownDeviceInfos
    ) {
        knownDeviceInfos.observe(this) {
            devicesPreference?.apply {
                if (it.count() > 1) {
                    title = it
                        .sortedWith(compareBy { it.connected })
                        .reversed()
                        .map {
                            if (it.connected) {
                                "${it.name}"
                            } else {
                                "⚠ ${it.name}"
                            }
                        }.joinToString(", ")
                    summary = null
                } else {
                    val deviceInfo = it?.lastOrNull()
                    if (deviceInfo != null) {
                        title = deviceInfo.name
                        summary = if (deviceInfo.connected)
                            getString(R.string.device_label_connected)
                        else
                            getString(R.string.device_label_not_connected)
                    } else {
                        title = getString(R.string.no_devices_preference_title)
                        summary = getString(R.string.no_devices_preference_summary)
                    }
                }
                setOnPreferenceClickListener { preference ->
                    Log.d(TAG, "preferenceClicked: $preference")
                    resolveLink(
                        "do://reconnect-connectiq",
                        this@SettingsFragment
                    )
                    false
                }
            }
        }
    }

    private fun setupPermissionPreference(
        preference: Preference?,
        title: Int,
        summaryOn: Int,
        summaryOff: Int,
        summaryOffDueToDependency: Int = 0
    ) {
        preference?.apply {
            val dependencyIsOff = lazy {
                (dependency != null) && !sharedPreferences!!.getBoolean(dependency, false)
            }
            if (disableExtrasWithEssentials && dependencyIsOff.value) {
                Log.d(TAG, "preference.$key.disabledDue: $dependency")
                isEnabled = false
                summary = getString(summaryOffDueToDependency)
            } else {
                isEnabled = true
                val isOn = sharedPreferences!!.getBoolean(key, false)
                Log.d(TAG, "preference.$key.isOn: $isOn")
                val titleFormat = if (isOn) {
                    getString(R.string.settings_preference_enabled_fmt)
                } else {
                    getString(R.string.settings_preference_disabled_fmt)
                }
                val formattedTitle = titleFormat.replace("{{title}}", getString(title))
                setTitle(formattedTitle)
                summary = if (isOn) {
                    getString(summaryOn)
                } else {
                    getString(summaryOff)
                }
            }
            setOnPreferenceClickListener { preference ->
                Log.d(TAG, "preferenceClicked: $preference")
                resolveLink(
                    "link://onboarding_${preference.key}?preferenceKey=${preference.key}",
                    this@SettingsFragment,
                    getString(R.string.settings_preferences_subscreen)
                )
                false
            }
        }
    }

    private fun setupContactsPreference() {
        contactsPreference?.apply {
            summary = getString(R.string.settings_contacts_off)
            setOnPreferenceClickListener { preference ->
                Log.d(TAG, "preferenceClicked: $preference")
                resolveLink(
                    "contacts://starred",
                    this@SettingsFragment
                )
                false
            }
        }
    }

    private val devicesPreference: Preference?
        get() {
            return findPreference("devices")
        }

    private val essentialsPreference: Preference?
        get() {
            return findPreference("essentials")
        }

    private val outgoingCallsPreference: Preference?
        get() {
            return findPreference("outgoing_calls")
        }

    private val callInfoPreference: Preference?
        get() {
            return findPreference("full_featured")
        }

    private val contactsPreference: Preference?
        get() {
            return findPreference("contacts")
        }

    companion object {
        private val TAG = SettingsFragment::class.java.simpleName
    }
}

private const val disableExtrasWithEssentials = false