package com.gentin.connectiq.handsfree.impl

typealias AppConfig = Int

const val AppConfig_Broadcast = 0b1
const val AppConfig_FullFeatured = 0b10
const val AppConfig_IncomingCalls = 0b100

fun isLowMemory(appConfig: AppConfig): Boolean {
    return (appConfig and AppConfig_FullFeatured) == 0
}

fun isBroadcastEnabled(appConfig: AppConfig): Boolean {
    return (appConfig and AppConfig_Broadcast) != 0
}

fun isIncomingCallsEnabled(appConfig: AppConfig): Boolean {
    return (appConfig and AppConfig_IncomingCalls) != 0
}