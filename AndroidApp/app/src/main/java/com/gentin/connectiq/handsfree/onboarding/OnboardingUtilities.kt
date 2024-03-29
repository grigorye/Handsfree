import android.app.Activity
import android.util.Log
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.permissions.batteryOptimizationPermissionsHandler
import com.gentin.connectiq.handsfree.permissions.newManifestPermissionsHandler
import com.gentin.connectiq.handsfree.permissions.overlayPermissionsHandler
import java.net.URI

fun resolveLink(link: String, fragment: Fragment) {
    val tag = object {}.javaClass.enclosingMethod?.name
    val context: Activity = fragment.requireActivity()
    Log.d(tag, "link: $link")
    val url = URI(link)
    when (url.scheme) {
        "link" -> {
            val resourceName = url.host
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
            when (url.host) {
                "manifest" -> {
                    val permissions = url.query.split("&")
                    val handler = newManifestPermissionsHandler(permissions)
                    Log.d(tag, "hasPermission($permissions): ${handler.hasPermission(context)}")
                    handler.requestPermission(context)
                }

                "battery_optimization" -> {
                    batteryOptimizationPermissionsHandler.requestPermission(context)
                }

                "draw_overlays" -> {
                    overlayPermissionsHandler.requestPermission(context)
                }
            }
        }
    }
}

private fun getStringResourceIdByName(name: String, fragment: Fragment): Int {
    val packageName = fragment.activity?.packageName
    val resId = fragment.resources.getIdentifier(name, "string", packageName)
    return resId
}

fun preprocessPermissionsInMarkdown(context: Activity, markdown: String): String {
    val tag = object {}.javaClass.enclosingMethod?.name
    return markdown
        .replace("\\[.*\\]\\(permission://manifest\\?(.*)\\)".toRegex()) {
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
        .replace("\\[.*\\]\\(permission://battery_optimization\\)".toRegex()) {
            val hasPermission = batteryOptimizationPermissionsHandler.hasPermission(context)
            val suffix = if (hasPermission) {
                " (Granted)"
            } else {
                " (Grant permission)"
            }
            it.value + suffix
        }
        .replace("\\[.*\\]\\(permission://draw_overlays\\)".toRegex()) {
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