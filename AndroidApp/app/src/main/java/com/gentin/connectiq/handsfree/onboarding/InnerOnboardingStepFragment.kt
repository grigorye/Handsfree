package com.gentin.connectiq.handsfree.onboarding

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.navigation.fragment.navArgs
import androidx.preference.SwitchPreferenceCompat
import com.gentin.connectiq.handsfree.DynamicSettingsFragment
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.permissions.PermissionHandler

class InnerOnboardingStepFragment : OnboardingStepFragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        if (args.preferenceKey != null) {
            embedSettings()
        }
    }

    override val preprocessedMarkdown: String
        get() {
            if (args.preferenceKey != null) {
                return stripHeaderFromMarkdown(super.preprocessedMarkdown)
            } else {
                return super.preprocessedMarkdown
            }
        }

    private fun embedSettings() {
        val activity = requireActivity()
        val settingsFragment = DynamicSettingsFragment {
            it.apply {
                val context = preferenceManager.context
                val preference = SwitchPreferenceCompat(context).apply {
                    key = args.preferenceKey
                    title = args.navigationLabel
                    isIconSpaceReserved = false
                    isSingleLineTitle = false
                    setOnPreferenceChangeListener { preference, newValue ->
                        Log.d(TAG, "preferenceChanged: $preference, $newValue")

                        val isOn = newValue as Boolean
                        if (isOn) {
                            val permissionHandlers =
                                preprocessPermissionsInMarkdown(
                                    activity,
                                    unprocessedMarkdown
                                ).permissionHandlers
                            requestPermissionsWithRationale(permissionHandlers, activity, null)
                        }
                        true
                    }
                }

                val preferenceScreen = preferenceManager.createPreferenceScreen(context)
                preferenceScreen.addPreference(preference)
                this.preferenceScreen = preferenceScreen
            }
        }
        activity.supportFragmentManager.beginTransaction()
            .replace(R.id.fragment_container_view, settingsFragment)
            .addToBackStack(null)
            .commit()
    }

    private val permissionHandlers: List<PermissionHandler> by lazy {
        preprocessPermissionsInMarkdown(requireActivity(), unprocessedMarkdown).permissionHandlers
    }

    private val args: InnerOnboardingStepFragmentArgs by navArgs()

    companion object {
        private val TAG = InnerOnboardingStepFragment::class.java.simpleName
    }
}

fun stripHeaderFromMarkdown(markdown: String): String {
    val lines = markdown.split("\n")
    return lines.drop(1).joinToString("\n")
}