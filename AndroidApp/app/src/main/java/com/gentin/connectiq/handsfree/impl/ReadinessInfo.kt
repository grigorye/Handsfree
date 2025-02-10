package com.gentin.connectiq.handsfree.impl

import android.content.Context
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.Readiness
import com.gentin.connectiq.handsfree.globals.essentialsAreOn
import com.gentin.connectiq.handsfree.globals.incomingCallsAreOn
import com.gentin.connectiq.handsfree.globals.outgoingCallsAreOn
import com.gentin.connectiq.handsfree.globals.readiness
import com.gentin.connectiq.handsfree.globals.recentsAreOn
import com.gentin.connectiq.handsfree.globals.starredContactsAreOn
import com.gentin.connectiq.handsfree.onboarding.preprocessPermissionsInMarkdown
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ReadinessInfo(
    @SerialName("e") val essentials: Readiness,
    @SerialName("o") val outgoingCalls: Readiness,
    @SerialName("s") val starredContacts: Readiness,
    @SerialName("r") val recents: Readiness,
    @SerialName("i") val incomingCalls: Readiness
)

fun readinessInfo(context: Context): ReadinessInfo {
    val readinessInfo = ReadinessInfo(
        essentials = readiness(
            essentialsAreOn(context),
            hasRequiredPermissionsForEssentials(context),
        ),
        outgoingCalls = readiness(
            outgoingCallsAreOn(context),
            hasRequiredPermissionsForOutgoingCalls(context)
        ),
        incomingCalls = readiness(
            incomingCallsAreOn(context),
            hasRequiredPermissionsForIncomingCalls(context)
        ),
        recents = readiness(
            recentsAreOn(context),
            hasRequiredPermissionsForRecents(context)
        ),
        starredContacts = readiness(
            starredContactsAreOn(context),
            hasRequiredPermissionsForStarredContacts(context)
        )
    )
    return readinessInfo
}

fun hasRequiredPermissionsForEssentials(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_essentials)
}

fun hasRequiredPermissionsForStarredContacts(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_starred_contacts)
}

fun hasRequiredPermissionsForOutgoingCalls(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_outgoing_calls)
}

fun hasRequiredPermissionsForIncomingCalls(context: Context): Boolean {
    return requiredPermissionsGranted(context, R.string.onboarding_incoming_calls)
}

fun hasRequiredPermissionsForRecents(context: Context): Boolean {
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