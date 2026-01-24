package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.content.SharedPreferences
import com.gentin.connectiq.handsfree.R
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class DeviceInfoFormattingTest {

    private lateinit var mockContext: Context
    private lateinit var mockPrefs: SharedPreferences

    @Before
    fun setUp() {
        mockContext = mockk()
        mockPrefs = mockk()

        every { mockContext.packageName } returns "com.gentin.connectiq.handsfree"
        every { mockContext.getSharedPreferences(any(), any()) } returns mockPrefs
        every { mockPrefs.getBoolean(any(), any()) } returns true

        every { mockContext.getString(R.string.settings_device_with_symbol_fmt) } returns "{{symbol}} {{device_name}}"
        every { mockContext.getString(R.string.settings_device_symbol_conflicting) } returns "⚔"
        every { mockContext.getString(R.string.settings_device_symbol_active) } returns "✔"
        every { mockContext.getString(R.string.settings_device_symbol_standby) } returns "standby"
        every { mockContext.getString(R.string.settings_device_symbol_loading) } returns "..."
        every { mockContext.getString(R.string.settings_device_symbol_missing_app) } returns "❓"
        every { mockContext.getString(R.string.settings_device_symbol_not_connected) } returns "disconnect"
        every { mockContext.getString(R.string.settings_device_suffix_silent) } returns "silent"
    }

    @Test
    fun `formattedFilteredDeviceInfos with empty list`() {
        // Given
        val deviceInfos = emptyList<DeviceInfo>()

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = false,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "", appConflict = false), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with single connected device and no apps`() {
        // Given
        val deviceInfo = DeviceInfo("fenix 7", { true }, { emptyList() })
        val deviceInfos = listOf(deviceInfo)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = false,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "❓ fenix 7", appConflict = false), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with single connected device with app`() {
        // Given
        val appConfig = AppConfig_Broadcast or AppConfig_IncomingCalls or AppConfig_FullFeatured
        val appInfo = InstalledAppInfo({ appConfig }, WatchAppVersionInfo(2, "app1"))
        val deviceInfo = DeviceInfo("fenix 7", { true }, { listOf(appInfo) })
        val deviceInfos = listOf(deviceInfo)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = false,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "✔ fenix 7 ($appConfig)", appConflict = false), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with single connected device with loading app`() {
        // Given
        val appInfo = InstalledAppInfo({ null }, WatchAppVersionInfo(2, "app1"))
        val deviceInfo = DeviceInfo("fenix 7", { true }, { listOf(appInfo) })
        val deviceInfos = listOf(deviceInfo)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = false,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "... fenix 7 (null)", appConflict = false), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with multiple connected devices`() {
        // Given
        val appConfig = AppConfig_Broadcast or AppConfig_IncomingCalls or AppConfig_FullFeatured
        val appInfo = InstalledAppInfo({ appConfig }, WatchAppVersionInfo(2, "app1"))
        val deviceInfo1 = DeviceInfo("fenix 7", { true }, { listOf(appInfo) })
        val deviceInfo2 = DeviceInfo("Instinct 3 - 45mm, Solar", { true }, { emptyList() })
        val deviceInfos = listOf(deviceInfo1, deviceInfo2)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = false,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "✔ fenix 7 ($appConfig)", appConflict = false), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with multiple connected devices with app conflict`() {
        // Given
        val appConfig = AppConfig_Broadcast or AppConfig_IncomingCalls or AppConfig_FullFeatured
        val appInfo = InstalledAppInfo({ appConfig }, WatchAppVersionInfo(2, "app1"))
        val deviceInfo1 = DeviceInfo("fenix 7", { true }, { listOf(appInfo) })
        val deviceInfo2 = DeviceInfo("Instinct 3 - 45mm, Solar", { true }, { listOf(appInfo) })
        val deviceInfos = listOf(deviceInfo1, deviceInfo2)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = false,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "⚔ fenix 7 ($appConfig), ⚔ Instinct 3 - 45mm, Solar ($appConfig)", appConflict = true), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with single connected device with app tailored for notifications`() {
        // Given
        val appConfig = AppConfig_Broadcast or AppConfig_IncomingCalls or AppConfig_FullFeatured
        val appInfo = InstalledAppInfo({ appConfig }, WatchAppVersionInfo(2, "app1"))
        val deviceInfo = DeviceInfo("fenix 7", { true }, { listOf(appInfo) })
        val deviceInfos = listOf(deviceInfo)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = true,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "fenix 7", appConflict = false), result)
    }

    @Test
    fun `formattedFilteredDeviceInfos with multiple connected devices with app conflict tailored for notifications`() {
        // Given
        val appConfig = AppConfig_Broadcast or AppConfig_IncomingCalls or AppConfig_FullFeatured
        val appInfo = InstalledAppInfo({ appConfig }, WatchAppVersionInfo(2, "app1"))
        val deviceInfo1 = DeviceInfo("fenix 7", { true }, { listOf(appInfo) })
        val deviceInfo2 = DeviceInfo("Instinct 3 - 45mm, Solar", { true }, { listOf(appInfo) })
        val deviceInfos = listOf(deviceInfo1, deviceInfo2)

        // When
        val result = formattedFilteredDeviceInfos(
            deviceInfos,
            mockContext,
            tailorForNotifications = true,
            separator = ", "
        )

        // Then
        assertEquals(FormattedDeviceInfos(text = "fenix 7, Instinct 3 - 45mm, Solar", appConflict = true), result)
    }
}
