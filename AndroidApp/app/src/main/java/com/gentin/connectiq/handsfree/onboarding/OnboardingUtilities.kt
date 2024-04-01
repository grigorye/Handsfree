package com.gentin.connectiq.handsfree.onboarding

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.contacts.openFavorites
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.startConnector
import com.gentin.connectiq.handsfree.permissions.PermissionStatus
import com.gentin.connectiq.handsfree.permissions.PermissionHandler
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
            val resourceName: String = host
            Log.d(tag, "destinationResourceName: $resourceName")
            val resourceId = getStringResourceIdByName(resourceName, fragment)
            Log.d(tag, "destinationResourceId: $resourceId")
            fragment.findNavController().navigate(
                R.id.link,
                bundleOf(
                    "markdown" to resourceId,
                    "navigationLabel" to headerFromMarkdown(fragment.getString(resourceId))
                )
            )
        }

        "permission" -> {
            when (uri.host) {
                "manifest" -> {
                    val query = uri.query
                    if (query == null) {
                        Log.e(tag, "missingQuery: $uri")
                        return
                    }
                    val permissions = query.split("&")
                    val handler = newManifestPermissionHandler(permissions)
                    val permissionStatus = handler.permissionStatus(context)
                    Log.d(tag, "permissionStatus($permissions): $permissionStatus")
                    navigatePermissionsLink(context, fragment.view, handler)
                }

                "battery_optimization" -> {
                    val handler = batteryOptimizationPermissionHandler
                    val permissionStatus = handler.permissionStatus(context)
                    Log.d(tag, "permissionStatus(batteryOptimization): $permissionStatus")
                    navigatePermissionsLink(context, fragment.view, handler)
                }

                "draw_overlays" -> {
                    val handler = overlayPermissionHandler
                    val permissionStatus = handler.permissionStatus(context)
                    Log.d(tag, "hasPermission(overlay): $permissionStatus")
                    navigatePermissionsLink(context, fragment.view, handler)
                }
            }
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

private fun navigatePermissionsLink(
    context: Activity,
    contextView: View?,
    permissionHandler: PermissionHandler
) {
    when (permissionHandler.permissionStatus(context)) {
        PermissionStatus.Granted -> {
            contextView?.apply {
                Snackbar
                    .make(
                        this,
                        R.string.permissions_snackbar_permission_is_already_granted,
                        Snackbar.LENGTH_SHORT
                    )
                    .setAction(R.string.permissions_snackbar_app_settings_btn) {
                        openAppSettings(context)
                    }
                    .show()
            }
        }

        PermissionStatus.NotGranted -> {
            permissionHandler.requestPermission(context)
        }

        PermissionStatus.Denied -> {
            contextView?.apply {
                Snackbar
                    .make(
                        this,
                        R.string.permissions_snackbar_permission_is_denied,
                        Snackbar.LENGTH_SHORT
                    )
                    .setAction(R.string.permissions_snackbar_app_settings_btn) {
                        openAppSettings(context)
                    }
                    .show()
            }
        }
    }
}

@SuppressLint("DiscouragedApi")
private fun getStringResourceIdByName(name: String, fragment: Fragment): Int {
    val packageName = fragment.activity?.packageName
    return fragment.resources.getIdentifier(name, "string", packageName)
}

fun preprocessPermissionsInMarkdown(context: Activity, markdown: String): String {
    val tag = object {}.javaClass.enclosingMethod?.name
    return markdown
        .replace("\\[([^]]*)]\\((permissions://([^)]*))\\)".toRegex()) {
            val linkText = it.groupValues[1]
            val uriString = it.groupValues[2]
            val uri = Uri.parse(uriString)
            val permissionHandlers = permissionHandlersForLink(uri)
            var hasPermission = true
            for (permissionHandler in permissionHandlers) {
                if (!permissionHandler.hasPermission(context)) {
                    hasPermission = false
                }
            }
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
    val handlers = ArrayList<PermissionHandler>()
    val manifestPermissionsArg = uri.getQueryParameter("manifest")
    if (manifestPermissionsArg != null) {
        val manifestPermissions = manifestPermissionsArg.split(",")
        handlers.add(newManifestPermissionHandler(manifestPermissions))
    }
    val batteryPermissionArg = uri.getQueryParameterNames().contains("battery_optimization")
    if (batteryPermissionArg) {
        handlers.add(batteryOptimizationPermissionHandler)
    }
    val overlayPermissionArg = uri.getQueryParameterNames().contains("draw_overlays")
    if (overlayPermissionArg) {
        handlers.add(overlayPermissionHandler)
    }
    return handlers
}