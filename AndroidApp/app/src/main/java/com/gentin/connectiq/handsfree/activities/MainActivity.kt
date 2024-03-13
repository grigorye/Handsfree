package com.gentin.connectiq.handsfree.activities

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.AppCompatButton
import com.gentin.connectiq.handsfree.BuildConfig
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.contacts.openFavorites
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.gentin.connectiq.handsfree.impl.startConnector
import com.gentin.connectiq.handsfree.permissions.anyPermissionMissing
import com.gentin.connectiq.handsfree.permissions.requestPermissions
import dev.doubledot.doki.ui.DokiActivity


fun versionInfo(): String {
    return arrayOf(
        BuildConfig.VERSION_NAME,
        "(" + BuildConfig.VERSION_CODE + ")",
        BuildConfig.SOURCE_VERSION,
        "(" + BuildConfig.BUILD_TYPE + ")",
    ).joinToString(" ")
}

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate")
        Log.d(TAG, "versionInfo: ${versionInfo()}")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        findViewById<AppCompatButton>(R.id.open_contacts_btn)?.setOnClickListener {
            openFavorites(this)
        }
        findViewById<AppCompatButton>(R.id.launch_doki_btn)?.setOnClickListener {
            DokiActivity.start(this)
        }
        findViewById<AppCompatButton>(R.id.reconnect_btn)?.setOnClickListener {
            startConnector(this, ACTIVATE_AND_RECONNECT)
        }
        findViewById<AppCompatButton>(R.id.permissions_info_btn)?.setOnClickListener {
            val builder: AlertDialog.Builder = AlertDialog.Builder(this)
            builder
                .setMessage(R.string.permissions_explanation)
                .setTitle(R.string.permissions_dialog_title)
                .setPositiveButton(R.string.permissions_dialog_proceed_btn) { dialog, which ->
                }
            val dialog: AlertDialog = builder.create()
            dialog.show()
        }
        findViewById<AppCompatButton>(R.id.grant_permissions_btn)?.setOnClickListener {
            if (!anyPermissionMissing(this)) {
                val builder: AlertDialog.Builder = AlertDialog.Builder(this)
                builder
                    .setMessage(R.string.all_permissions_are_granted_message)
                    .setPositiveButton(R.string.all_permissions_are_granted_ok_btn) { dialog, which ->
                    }
                val dialog: AlertDialog = builder.create()
                dialog.show()
            } else {
                requestPermissions(this)
            }
        }
        findViewById<TextView>(R.id.version_info_txt)?.text = versionInfo()

        startConnector(this, ACTIVATE_FROM_MAIN_ACTIVITY_ACTION)
    }

    public override fun onPause() {
        Log.d(TAG, "onPause")
        super.onPause()
    }

    public override fun onResume() {
        Log.d(TAG, "onResume")
        startConnector(this, ACTIVATE_FROM_MAIN_ACTIVITY_ACTION)
        super.onResume()
    }

    public override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        super.onDestroy()
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }
}
