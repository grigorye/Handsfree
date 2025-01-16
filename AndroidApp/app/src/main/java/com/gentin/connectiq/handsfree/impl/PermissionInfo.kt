package com.gentin.connectiq.handsfree.impl

import android.content.Context
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.outgoingCallsShouldBeEnabled
import com.gentin.connectiq.handsfree.onboarding.preprocessPermissionsInMarkdown
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PermissionInfo(
    @SerialName("e") val essentials: Boolean,
    @SerialName("o") val outgoingCalls: Boolean,
    @SerialName("s") val starredContacts: Boolean,
    @SerialName("r") val recents: Boolean,
    @SerialName("i") val incomingCalls: Boolean
)

fun permissionInfo(context: Context): PermissionInfo {
    return PermissionInfo(
        essentials = hasRequiredPermissionsForEssentials(context),
        outgoingCalls = arrayOf(
            hasRequiredPermissionsForEssentials(context),
            hasRequiredPermissionsForOutgoingCalls(context)
        ).all { it },
        incomingCalls = arrayOf(
            hasRequiredPermissionsForEssentials(context),
            hasRequiredPermissionsForIncomingCalls(context)
        ).all { it },
        recents = hasRequiredPermissionsForRecents(context),
        starredContacts = hasRequiredPermissionsForStarredContacts(context)
    )
}

private fun hasRequiredPermissionsForEssentials(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_essentials)
}

private fun hasRequiredPermissionsForStarredContacts(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_starred_contacts)
}

private fun hasRequiredPermissionsForOutgoingCalls(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_outgoing_calls)
}

private fun hasRequiredPermissionsForIncomingCalls(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_incoming_calls)
}

private fun hasRequiredPermissionsForRecents(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_recents)
}

private fun requiredPermissionsGranted(context: Context, resourceId: Int): Boolean {
    val markdown = context.getString(resourceId)
    val permissionHandlers = preprocessPermissionsInMarkdown(
        context, markdown
    ).permissionHandlers

    val hasAllRequiredPermissions =
        permissionHandlers.all { permissionHandler -> permissionHandler.hasRequiredPermission(context) }
    return hasAllRequiredPermissions
}