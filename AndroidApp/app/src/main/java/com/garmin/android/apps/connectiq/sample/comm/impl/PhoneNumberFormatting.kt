package com.garmin.android.apps.connectiq.sample.comm.impl

import android.telephony.PhoneNumberUtils
import java.util.Locale

fun formatPhoneNumber(phoneNumber: String): String {
    return PhoneNumberUtils.formatNumber(
        phoneNumber,
        Locale.getDefault().country
    )
}

fun normalizePhoneNumber(phoneNumber: String): String {
    return PhoneNumberUtils.normalizeNumber(phoneNumber)
}