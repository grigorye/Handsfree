package com.gentin.connectiq.handsfree.activities

import android.app.Activity
import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.util.Log
import android.view.View.GONE
import android.view.View.VISIBLE
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.AppCompatButton
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.contacts.openFavorites
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.gentin.connectiq.handsfree.impl.startConnector
import com.gentin.connectiq.handsfree.impl.versionInfo
import com.gentin.connectiq.handsfree.permissions.anyPermissionMissing
import com.gentin.connectiq.handsfree.permissions.openAppSettings
import com.gentin.connectiq.handsfree.permissions.requestPermissions
import dev.doubledot.doki.ui.DokiActivity
import io.noties.markwon.Markwon


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
        findViewById<TextView>(R.id.intro_txt)?.apply {
            movementMethod = LinkMovementMethod.getInstance()
        }

        showPermissionsButton?.setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle(R.string.permissions_dialog_all_granted_title)
                .setMessage(permissionsExplanation)
                .setNeutralButton(R.string.permissions_dialog_app_settings_btn) { _, _ ->
                    openAppSettings(this)
                }
                .setPositiveButton(R.string.permissions_dialog_all_granted_ok_btn) { _, _ -> }
                .create()
                .show()
        }
        grantPermissionsButton?.setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle(R.string.permissions_dialog_proceed_title)
                .setMessage(permissionsExplanation)
                .setPositiveButton(R.string.permissions_dialog_proceed_btn) { _, _ ->
                    requestPermissions(this)
                }
                .setNeutralButton(R.string.permissions_dialog_app_settings_btn) { _, _ ->
                    openAppSettings(this)
                }
                .setNegativeButton(R.string.permissions_dialog_do_not_proceed_btn) { _, _ ->
                }
                .create()
                .show()
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

        if (anyPermissionMissing(this)) {
            showPermissionsButton?.visibility = GONE
            grantPermissionsButton?.visibility = VISIBLE
        } else {
            showPermissionsButton?.visibility = VISIBLE
            grantPermissionsButton?.visibility = GONE
        }
    }

    private val showPermissionsButton: Button? by lazy {
        findViewById<AppCompatButton>(R.id.show_permissions_btn)
    }

    private val grantPermissionsButton: Button? by lazy {
        findViewById<AppCompatButton>(R.id.grant_permissions_btn)
    }

    private val permissionsExplanation by lazy {
        val markwon = Markwon.create(this)
        val explanation = markwon.toMarkdown(getString(R.string.permissions_explanation_markdown))
        explanation
    }

    public override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        super.onDestroy()
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }
}
