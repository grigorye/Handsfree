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
import com.gentin.connectiq.handsfree.permissions.PermissionsHandler
import com.gentin.connectiq.handsfree.permissions.batteryOptimizationPermissionsHandler
import com.gentin.connectiq.handsfree.permissions.newManifestPermissionsHandler
import com.gentin.connectiq.handsfree.permissions.openAppSettings
import com.gentin.connectiq.handsfree.permissions.overlayPermissionsHandler
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
                    val handler = newManifestPermissionsHandler(permissions)
                    val hasPermission = handler.hasPermission(context)
                    Log.d(tag, "hasPermission($permissions): $hasPermission")
                    navigatePermissionsLink(context, fragment.view, handler)
                }

                "battery_optimization" -> {
                    val handler = batteryOptimizationPermissionsHandler
                    val hasPermission = handler.hasPermission(context)
                    Log.d(tag, "hasPermission(batteryOptimization): $hasPermission")
                    navigatePermissionsLink(context, fragment.view, handler)
                }

                "draw_overlays" -> {
                    val handler = overlayPermissionsHandler
                    val hasPermission = handler.hasPermission(context)
                    Log.d(tag, "hasPermission(overlay): $hasPermission")
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
    permissionsHandler: PermissionsHandler
) {
    if (permissionsHandler.hasPermission(context)) {
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
    } else {
        permissionsHandler.requestPermission(context)
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
        .replace("\\[.*]\\(permission://manifest\\?(.*)\\)".toRegex()) {
            val permissions = it.groupValues[1].split("&")
            Log.d(tag, "permissions: $permissions")
            val hasPermission =
                newManifestPermissionsHandler(permissions).hasPermission(context)
            val suffix = if (hasPermission) {
                " (Granted)"
            } else {
                " (Grant permission)"
            }
            it.value + suffix
        }
        .replace("\\[.*]\\(permission://battery_optimization\\)".toRegex()) {
            val hasPermission = batteryOptimizationPermissionsHandler.hasPermission(context)
            val suffix = if (hasPermission) {
                " (Granted)"
            } else {
                " (Grant permission)"
            }
            it.value + suffix
        }
        .replace("\\[.*]\\(permission://draw_overlays\\)".toRegex()) {
            val hasPermission = overlayPermissionsHandler.hasPermission(context)
            val suffix = if (hasPermission) {
                " (Granted)"
            } else {
                " (Grant permission)"
            }
            it.value + suffix
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