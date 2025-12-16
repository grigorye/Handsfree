package com.gentin.connectiq.handsfree.helpers

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.util.Log

enum class BluetoothStatus {
    Disabled,
    On,
    Off,
    NotSupported
}

interface BluetoothConnector {
    fun bluetoothStatus(context: Context): BluetoothStatus
}

class BluetoothConnectorImp: BluetoothConnector {
    override fun bluetoothStatus(context: Context): BluetoothStatus {
        val btManager = context.getSystemService(BluetoothManager::class.java)
        val adapter: BluetoothAdapter = btManager?.adapter ?: return BluetoothStatus.NotSupported

        if (!adapter.isEnabled) {
            return BluetoothStatus.Disabled
        }
        when (adapter.state) {
            BluetoothAdapter.STATE_OFF -> {
                return BluetoothStatus.Off
            }

            BluetoothAdapter.STATE_ON -> {
                return BluetoothStatus.On
            }

            BluetoothAdapter.STATE_TURNING_OFF -> {
                return BluetoothStatus.Off
            }

            BluetoothAdapter.STATE_TURNING_ON -> {
                return BluetoothStatus.Off
            }

            else -> {
                Log.e(TAG, "unknownBluetoothState: ${adapter.state}")
                return BluetoothStatus.Off
            }
        }
    }

    companion object {
        private val TAG: String = BluetoothConnector::class.java.simpleName
    }
}