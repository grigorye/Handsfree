package com.gentin.connectiq.handsfree.globals

import com.garmin.android.connectiq.IQApp
import com.gentin.connectiq.handsfree.helpers.isRunningInEmulator

private val simApp = IQApp("")
val prodApp = IQApp("76526066-d191-46f4-9cfb-bbf9ed955b23")
private val betaApp = IQApp("a3d8da80-e013-41f9-aca4-f66bb38fad3f")
private val prodWidget = IQApp("4241a52e-81db-4356-ac43-c8dfeb7d0be0")
private val betaWidget = IQApp("cdc225d9-bc88-4d9e-a8a6-ce7dffdd0714")

val watchApps = if (isRunningInEmulator()) {
    listOf(simApp)
} else {
    listOf(prodApp, betaApp, prodWidget, betaWidget)
}

fun appLogName(app: IQApp): String {
    return when (app) {
        simApp -> "sim"
        prodApp -> "prod"
        betaApp -> "beta"
        prodWidget -> "prod-w"
        betaWidget -> "beta-w"
        else -> "unknown"
    }
}
