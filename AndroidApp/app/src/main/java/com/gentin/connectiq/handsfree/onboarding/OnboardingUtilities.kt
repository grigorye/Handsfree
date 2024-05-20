package com.gentin.connectiq.handsfree.onboarding

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.contacts.openFavorites
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.knownDevicesMarkdown
import com.gentin.connectiq.handsfree.impl.startConnector
import com.gentin.connectiq.handsfree.impl.statusInfo
import com.gentin.connectiq.handsfree.impl.versionInfo
import com.gentin.connectiq.handsfree.permissions.PermissionHandler
import com.gentin.connectiq.handsfree.permissions.PermissionStatus
import com.gentin.connectiq.handsfree.permissions.batteryOptimizationPermissionHandler
import com.gentin.connectiq.handsfree.permissions.newManifestPermissionHandler
import com.gentin.connectiq.handsfree.permissions.openAppSettings
import com.gentin.connectiq.handsfree.permissions.overlayPermissionHandler
import com.google.android.material.snackbar.Snackbar
import dev.doubledot.doki.ui.DokiActivity


fun resolveLink(link: String, fragment: Fragment) {
    val tag = object {}.javaClass.enclosingMethod?.name
    val context: Activity = fragment.requireActivity()
    Log.d(tag, "link: $link")
    val uri = Uri.parse(link)
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
            navigateToResource(host, fragment, preferenceKey)
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
                        Snackbar
                            .make(
                                this,
                                R.string.overview_snackbar_reconnecting_connectiq,
                                Snackbar.LENGTH_SHORT
                            )
                            .show()
                    }
                }

                "doki" -> {
                    DokiActivity.start(context)
                }

                "settings" -> {
                    openAppSettings(context)
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
    preferenceKey: String? = null
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
            "navigationLabel" to headerFromMarkdown(fragment.getString(resourceId)),
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
        .replace("{{version_info}}", versionInfo())
        .replace("{{status_info}}", statusInfo())
        .replace("{{known_devices}}", knownDevicesMarkdown())
}

data class PreprocessedMarkdownWithPermissions(
    val markdown: String,
    val permissionHandlers: List<PermissionHandler>
)

fun preprocessPermissionsInMarkdown(
    context: Activity,
    markdown: String
): PreprocessedMarkdownWithPermissions {
    val tag = object {}.javaClass.enclosingMethod?.name

    val accumulatedPermissionLinks = ArrayList<Uri>()
    val preprocessedMarkdown = markdown
        .replace("\\[([^]]*)]\\((permissions://([^)]*))\\)".toRegex()) {
            val linkText = it.groupValues[1]
            val uriString = it.groupValues[2]
            val uri = Uri.parse(uriString)
            accumulatedPermissionLinks.add(uri)
            val permissionHandlers = permissionHandlersForLink(uri)
            var hasPermission = true
            for (permissionHandler in permissionHandlers) {
                if (!permissionHandler.hasPermission(context)) {
                    hasPermission = false
                }
            }
            if (disarmPermissionLinks) {
                linkText
            } else {
                val format = if (hasPermission) {
                    context.getString(R.string.markdown_link_permission_granted_fmt)
                } else {
                    context.getString(R.string.markdown_link_permission_not_granted_fmt)
                }
                format
                    .replace("{{link_text}}", linkText)
                    .replace("{{link_url}}", uriString)
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
    val accumulatedManifestPermissions = ArrayList<String>()
    for (uri in uris) {
        val manifestPermissionsArg = uri.getQueryParameter("manifest")
        if (manifestPermissionsArg != null) {
            val manifestPermissions = manifestPermissionsArg.split(",")
            accumulatedManifestPermissions += manifestPermissions
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
    if (accumulatedManifestPermissions.isNotEmpty()) {
        handlers.add(newManifestPermissionHandler(accumulatedManifestPermissions))
    }
    return handlers
}