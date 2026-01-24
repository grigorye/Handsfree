package com.gentin.connectiq.handsfree.onboarding

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import androidx.core.net.toUri
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.activities.DokiEdgeToEdgeActivity
import com.gentin.connectiq.handsfree.contacts.openFavorites
import com.gentin.connectiq.handsfree.helpers.shareLog
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_OPEN_WATCH_APP_ON_DEVICE
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_PING
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.knownDevicesMarkdown
import com.gentin.connectiq.handsfree.impl.startConnector
import com.gentin.connectiq.handsfree.impl.statusInfo
import com.gentin.connectiq.handsfree.impl.versionInfoString
import com.gentin.connectiq.handsfree.permissions.PermissionHandler
import com.gentin.connectiq.handsfree.permissions.PermissionStatus
import com.gentin.connectiq.handsfree.permissions.batteryOptimizationPermissionHandler
import com.gentin.connectiq.handsfree.permissions.newManifestPermissionHandler
import com.gentin.connectiq.handsfree.permissions.openAppSettings
import com.gentin.connectiq.handsfree.permissions.openGarminConnectSettings
import com.gentin.connectiq.handsfree.permissions.overlayPermissionHandler
import com.gentin.connectiq.handsfree.services.GarminPhoneCallConnectorService
import com.google.android.material.snackbar.Snackbar


fun resolveLink(link: String, fragment: Fragment, navigationLabel: String? = null) {
    val tag = object {}.javaClass.enclosingMethod?.name
    val context: Activity = fragment.requireActivity()
    Log.d(tag, "link: $link")
    val uri = link.toUri()
    when (uri.scheme) {
        "https" -> {
            val browserIntent = Intent(Intent.ACTION_VIEW, uri)
            context.startActivity(browserIntent)
        }

        "link" -> {
            val host = uri.host
            if (host == null) {
                Log.e(tag, "missingHost: $uri")
                return
            }
            val preferenceKey = uri.getQueryParameter("preferenceKey")
            navigateToResource(host, fragment, preferenceKey, navigationLabel)
        }

        "permissions" -> {
            val handlers = permissionHandlersForLink(uri)

            requestPermissionsWithRationale(
                handlers,
                context,
                navigateToRationaleForLink(uri, fragment)
            )
        }

        "contacts" -> {
            when (uri.host) {
                "starred" -> {
                    openFavorites(context)
                }
            }
        }

        "do" -> {
            when (uri.host) {
                "reconnect-connectiq" -> {
                    startConnector(context, ACTIVATE_AND_RECONNECT)
                    val contextView = fragment.view
                    contextView?.apply {
                        val snackbar = Snackbar
                            .make(
                                this,
                                R.string.overview_snackbar_reconnecting_connectiq,
                                Snackbar.LENGTH_SHORT
                            )
                        val navBar = fragment.requireActivity().findViewById<View>(R.id.nav_bar_view)
                        if (navBar?.isShown == true) {
                            snackbar.anchorView = navBar
                        }
                        snackbar.show()
                    }
                }

                "doki" -> {
                    DokiEdgeToEdgeActivity.start(context)
                }

                "settings" -> {
                    openAppSettings(context)
                }

                "restart-service" -> {
                    restartGarminPhoneCallConnectorService(context)
                }

                "garmin-connect-settings" -> {
                    openGarminConnectSettings(context)
                }

                "toggle-debug-mode" -> {
                    toggleDebugMode(context, fragment)
                }

                "toggle-emulator-mode" -> {
                    toggleEmulatorMode(context, fragment)
                }

                "open-watch-app" -> {
                    startConnector(context, ACTIVATE_AND_OPEN_WATCH_APP_ON_DEVICE)
                }

                "ping" -> {
                    startConnector(context, ACTIVATE_AND_PING)
                    val contextView = fragment.view
                    contextView?.apply {
                        Snackbar
                            .make(
                                this,
                                "Pinging...",
                                Snackbar.LENGTH_SHORT
                            )
                            .show()
                    }
                }

                "open-app-in-store" -> {
                    startConnector(context, ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE)
                }

                "share-log" -> {
                    shareLog(context)
                }

                else -> {
                    Log.e(tag, "unknownDo: ${uri.host}")
                }
            }
        }

        else -> {
            Log.e(tag, "unknownScheme: ${uri.scheme}")
        }
    }
}

private fun restartGarminPhoneCallConnectorService(context: Context) {
    val intent = Intent(context, GarminPhoneCallConnectorService::class.java)
    context.stopService(intent)
    context.startService(intent)
}

fun requestPermissionsWithRationale(
    handlers: List<PermissionHandler>,
    context: Activity,
    navigateToRationale: (() -> Unit)?
) {
    val tag = object {}.javaClass.enclosingMethod?.name

    val handlersRequiringRationale = ArrayList<PermissionHandler>()
    val handlersNotGranted = ArrayList<PermissionHandler>()
    val handlersGranted = ArrayList<PermissionHandler>()
    for (handler in handlers) {
        when (handler.permissionStatus(context)) {
            PermissionStatus.NotGrantedNeedsRationale -> {
                handlersRequiringRationale.add(handler)
            }

            PermissionStatus.NotGranted -> {
                handlersNotGranted.add(handler)
            }

            PermissionStatus.Granted -> {
                handlersGranted.add(handler)
            }
        }
    }
    when {
        handlersRequiringRationale.isNotEmpty() -> {
            if (navigateToRationale != null) {
                navigateToRationale()
            } else {
                Log.d(tag, "noRationaleForPermissions: $handlersRequiringRationale")
                for (handler in handlersNotGranted + handlersRequiringRationale) {
                    handler.requestPermission(context)
                }
            }

        }

        handlersNotGranted.isNotEmpty() -> {
            for (handler in handlersNotGranted) {
                handler.requestPermission(context)
            }
        }

        else -> {
            Log.d(tag, "handlersGranted: $handlersGranted")
        }
    }
}

fun navigateToRationaleForLink(uri: Uri, fragment: Fragment): (() -> Unit)? {
    val tag = object {}.javaClass.enclosingMethod?.name

    val rationaleForPermissions = uri.host
    if (rationaleForPermissions.isNullOrBlank()) {
        Log.d(tag, "noRationaleForUri: $uri")
        return null
    } else {
        return {
            navigateToResource(rationaleForPermissions, fragment)
        }
    }
}

private fun navigateToResource(
    resourceName: String,
    fragment: Fragment,
    preferenceKey: String? = null,
    navigationLabel: String? = null
) {
    val tag = object {}.javaClass.enclosingMethod?.name

    Log.d(tag, "destinationResourceName: $resourceName")
    val resourceId = getStringResourceIdByName(resourceName, fragment)
    if (resourceId == 0) {
        Log.e(tag, "resourceNotFound: $resourceName")
        return
    }
    Log.d(tag, "destinationResourceId: $resourceId")
    fragment.findNavController().navigate(
        R.id.link,
        bundleOf(
            "markdown" to resourceId,
            "navigationLabel" to (navigationLabel ?: headerFromMarkdown(
                fragment.getString(
                    resourceId
                )
            )),
            "preferenceTitle" to headerFromMarkdown(fragment.getString(resourceId)),
            "preferenceKey" to preferenceKey,
            "hideHeader" to true
        )
    )
}

@SuppressLint("DiscouragedApi")
private fun getStringResourceIdByName(name: String, fragment: Fragment): Int {
    val packageName = fragment.activity?.packageName
    return fragment.resources.getIdentifier(name, "string", packageName)
}

fun preprocessMarkdown(context: Activity, markdown: String): String {
    return preprocessPermissionsInMarkdown(context, markdown)
        .markdown
        .replace("{{version_info}}", versionInfoString())
        .replace("{{status_info}}", statusInfo())
        .replace("{{known_devices}}", knownDevicesMarkdown())
}

data class PreprocessedMarkdownWithPermissions(
    val markdown: String,
    val permissionHandlers: List<PermissionHandler>
)

fun preprocessPermissionsInMarkdown(
    context: Context,
    markdown: String
): PreprocessedMarkdownWithPermissions {
    val tag = object {}.javaClass.enclosingMethod?.name

    val accumulatedPermissionLinks = ArrayList<Uri>()
    val preprocessedMarkdown = markdown
        .replace("\\[([^]]*)]\\((permissions://([^)]*))\\)".toRegex()) {
            val linkText = it.groupValues[1]
            val uriString = it.groupValues[2]
            val uri = uriString.toUri()
            accumulatedPermissionLinks.add(uri)
            val permissionHandlers = permissionHandlersForLink(uri)
            var isPermissionRequested = true
            for (permissionHandler in permissionHandlers) {
                if (!permissionHandler.isPermissionRequested(context)) {
                    isPermissionRequested = false
                }
            }
            var hasPermission = true
            for (permissionHandler in permissionHandlers) {
                if (!permissionHandler.hasPermission(context)) {
                    hasPermission = false
                }
            }
            if (disarmPermissionLinks) {
                linkText
            } else {
                val format = if (!isPermissionRequested) {
                    context.getString(R.string.settings_permission_not_available_fmt)
                } else if (hasPermission) {
                    context.getString(R.string.settings_permission_granted_fmt)
                } else {
                    context.getString(R.string.settings_permission_not_granted_fmt)
                }
                var result = format
                    .replace("{{link_text}}", linkText)
                    .replace("{{link_url}}", uriString)
                if (!isPermissionRequested) {
                    result += "\n" + context.getString(R.string.settings_permission_not_available_rationale)
                }
                result
            }
        }

    Log.d(tag, "accumulatedPermissionLinks: $accumulatedPermissionLinks")
    val permissionHandlers = permissionHandlersForLinks(accumulatedPermissionLinks)
    return PreprocessedMarkdownWithPermissions(preprocessedMarkdown, permissionHandlers)
}

const val disarmPermissionLinks = false

private fun headerFromMarkdown(markdown: String): String {
    val firstLine = markdown.split("\n")[0]
    return firstLine
        .dropWhile {
            it == '#'
        }
        .dropWhile {
            it == ' '
        }
}

private fun permissionHandlersForLink(uri: Uri): List<PermissionHandler> {
    return permissionHandlersForLinks(listOf(uri))
}

private fun permissionHandlersForLinks(uris: List<Uri>): List<PermissionHandler> {
    val handlers = ArrayList<PermissionHandler>()
    val accumulatedRequiredManifestPermissions = ArrayList<String>()
    val accumulatedOptionalManifestPermissions = ArrayList<String>()
    for (uri in uris) {
        val manifestPermissionsArg = uri.getQueryParameter("manifest")
        if (manifestPermissionsArg != null) {
            val manifestPermissions = manifestPermissionsArg.split(",")
            accumulatedRequiredManifestPermissions += manifestPermissions
        }
        val manifestOptionalPermissionsArg = uri.getQueryParameter("manifest_optional")
        if (manifestOptionalPermissionsArg != null) {
            val manifestPermissions = manifestOptionalPermissionsArg.split(",")
            accumulatedOptionalManifestPermissions += manifestPermissions
        }
        val batteryPermissionArg = uri.getQueryParameterNames().contains("battery_optimization")
        if (batteryPermissionArg) {
            handlers.add(batteryOptimizationPermissionHandler)
        }
        val overlayPermissionArg = uri.getQueryParameterNames().contains("draw_overlays")
        if (overlayPermissionArg) {
            handlers.add(overlayPermissionHandler)
        }
    }
    if (accumulatedRequiredManifestPermissions.isNotEmpty() || accumulatedOptionalManifestPermissions.isNotEmpty()) {
        handlers.add(
            newManifestPermissionHandler(
                accumulatedRequiredManifestPermissions,
                accumulatedOptionalManifestPermissions
            )
        )
    }
    return handlers
}