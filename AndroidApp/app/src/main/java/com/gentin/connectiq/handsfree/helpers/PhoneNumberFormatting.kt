package com.gentin.connectiq.handsfree.helpers

import android.content.Context
import android.telephony.PhoneNumberUtils
import android.telephony.TelephonyManager
import java.util.Locale


fun formatPhoneNumber(phoneNumber: String): String {
    return PhoneNumberUtils.formatNumber(
        phoneNumber,
        Locale.getDefault().country
    )
}

fun normalizePhoneNumber(context: Context, phoneNumber: String): String {
    val countryCode = (context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager).networkCountryIso

    return PhoneNumberUtils.formatNumberToE164(phoneNumber, countryCode) ?: phoneNumber
}