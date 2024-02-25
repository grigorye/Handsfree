package com.garmin.android.apps.connectiq.sample.comm.activities

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothDevice
import android.companion.AssociationInfo
import android.companion.AssociationRequest
import android.companion.BluetoothDeviceFilter
import android.companion.CompanionDeviceManager
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.ParcelUuid
import android.provider.Settings
import android.view.Menu
import android.view.MenuItem
import androidx.core.app.ActivityCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.garmin.android.apps.connectiq.sample.comm.R
import com.garmin.android.apps.connectiq.sample.comm.services.GarminPhoneCallConnectorService
import java.util.UUID
import java.util.concurrent.Executor
import java.util.regex.Pattern


class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.ANSWER_PHONE_CALLS,
                Manifest.permission.CALL_PHONE,
                Manifest.permission.FOREGROUND_SERVICE,
                Manifest.permission.FOREGROUND_SERVICE_SYSTEM_EXEMPTED,
                Manifest.permission.READ_CALL_LOG,
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.SCHEDULE_EXACT_ALARM,
            ),
            0
        )

        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, -1)
        }

        setupUi()
        startForegroundService(Intent(this, GarminPhoneCallConnectorService::class.java))
    }

    public override fun onResume() {
        super.onResume()
    }

    public override fun onDestroy() {
        super.onDestroy()
    }


    private fun setupUi() {
        findViewById<RecyclerView>(android.R.id.list).apply {
            layoutManager = LinearLayoutManager(this@MainActivity)
        }
    }


    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return super.onOptionsItemSelected(item)
    }
}