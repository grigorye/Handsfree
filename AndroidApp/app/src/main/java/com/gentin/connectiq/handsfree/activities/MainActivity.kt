package com.gentin.connectiq.handsfree.activities

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.Menu
import androidx.appcompat.widget.AppCompatButton
import androidx.core.app.ActivityCompat
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.helpers.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.helpers.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.gentin.connectiq.handsfree.helpers.startConnector
import com.gentin.connectiq.handsfree.impl.openFavorites
import com.gentin.connectiq.handsfree.impl.requestIgnoreBatteryOptimizations
import dev.doubledot.doki.ui.DokiActivity


class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        findViewById<AppCompatButton>(R.id.open_contacts_btn)?.let {
            it.setOnClickListener {
                openFavorites(this)
            }
        }
        findViewById<AppCompatButton>(R.id.launch_doki_btn)?.let {
            it.setOnClickListener {
                DokiActivity.start(this)
            }
        }
        findViewById<AppCompatButton>(R.id.reconnect_btn)?.let {
            it.setOnClickListener {
                startConnector(this, ACTIVATE_AND_RECONNECT)
            }
        }

        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.ANSWER_PHONE_CALLS,
                Manifest.permission.CALL_PHONE,
                Manifest.permission.FOREGROUND_SERVICE,
                Manifest.permission.FOREGROUND_SERVICE_SPECIAL_USE,
                Manifest.permission.POST_NOTIFICATIONS,
                Manifest.permission.READ_CALL_LOG,
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.RECEIVE_BOOT_COMPLETED,
                Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                Manifest.permission.SYSTEM_ALERT_WINDOW
            ),
            0
        )

        requestIgnoreBatteryOptimizations(this)

        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, -1)
        }

        setupUi()
        startConnector(this, ACTIVATE_FROM_MAIN_ACTIVITY_ACTION)
    }

    public override fun onPause() {
        Log.d(TAG, "onPause")
        super.onPause()
    }

    public override fun onResume() {
        Log.d(TAG, "onResume")
        super.onResume()
    }

    public override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        super.onDestroy()
    }

    private fun setupUi() {

    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.main, menu)
        return true
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }
}