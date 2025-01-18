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
import com.gentin.connectiq.handsfree.impl.formattedDeviceInfos
import com.gentin.connectiq.handsfree.impl.hasRequiredPermissionsForEssentials
import com.gentin.connectiq.handsfree.impl.hasRequiredPermissionsForIncomingCalls
import com.gentin.connectiq.handsfree.impl.hasRequiredPermissionsForOutgoingCalls
import com.gentin.connectiq.handsfree.impl.hasRequiredPermissionsForRecents
import com.gentin.connectiq.handsfree.impl.messageForDeviceInfos
import com.gentin.connectiq.handsfree.impl.refreshMessage
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
            R.string.settings_essentials_off,
            hasPermissions = { hasRequiredPermissionsForEssentials(requireContext()) }
        )
        setupPermissionPreference(
            outgoingCallsPreference,
            R.string.settings_outgoing_calls,
            R.string.settings_outgoing_calls_on,
            R.string.settings_outgoing_calls_off,
            R.string.settings_disabled_due_to_essentials_are_off,
            hasPermissions = { hasRequiredPermissionsForOutgoingCalls(requireContext()) },
        )
        setupPermissionPreference(
            recentsPreference,
            R.string.settings_recents,
            R.string.settings_recents_on,
            R.string.settings_recents_off,
            hasPermissions = { hasRequiredPermissionsForRecents(requireContext()) },
        )
        setupPermissionPreference(
            callInfoPreference,
            R.string.settings_call_info,
            R.string.settings_call_info_on,
            R.string.settings_call_info_off,
            R.string.settings_disabled_due_to_essentials_are_off,
            hasPermissions = { hasRequiredPermissionsForIncomingCalls(requireContext()) }
        )
        callInfoPreference?.isVisible =
            isPermissionRequested(requireActivity(), Manifest.permission.READ_CALL_LOG)
        setupContactsPreference()
    }

    private fun setupDevicesPreference(
        knownDeviceInfos: LiveData<List<DeviceInfo>> = DefaultServiceLocator.knownDeviceInfos
    ) {
        knownDeviceInfos.observe(this) {
            Log.d(TAG, "knownDeviceInfosDidChange: $it")
            devicesPreference?.apply {
                if (it.count() > 1) {
                    val message = messageForDeviceInfos(it)
                    val suffix = if (message != "") {
                        "\n\n" + message
                    } else {
                        ""
                    }
                    title = formattedDeviceInfos(it) + "\n\n" + refreshMessage + suffix
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
        summaryOffDueToDependency: Int = 0,
        hasPermissions: () -> Boolean = { true }
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
                    if (hasPermissions()) {
                        getString(R.string.settings_preference_enabled_fmt)
                    } else {
                        getString(R.string.settings_preference_enabled_no_perm_fmt)
                    }
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

    private val recentsPreference: Preference?
        get() {
            return findPreference("recents")
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