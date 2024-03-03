package com.garmin.android.apps.connectiq.sample.comm.impl

data class PhoneState(
    val incomingNumber: String?,
    val stateExtra: String
)

var lastTrackedPhoneState: PhoneState? = null
