/**
 * Copyright (C) 2015 Garmin International Ltd.
 * Subject to Garmin SDK License Agreement and Wearables Application Developer Agreement.
 */
package com.garmin.android.apps.connectiq.sample.comm.activities

import android.Manifest
import android.app.ActivityOptions
import android.app.AlertDialog
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import android.telecom.TelecomManager
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.lifecycle.LifecycleCoroutineScope
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.garmin.android.apps.connectiq.sample.comm.ContactsRepository
import com.garmin.android.apps.connectiq.sample.comm.MessageFactory
import com.garmin.android.apps.connectiq.sample.comm.R
import com.garmin.android.apps.connectiq.sample.comm.adapter.MessagesAdapter
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import org.json.JSONObject


private const val TAG = "DeviceActivity"
private const val EXTRA_IQ_DEVICE = "IQDevice"

// TODO Add a valid store app id.
private const val STORE_APP_ID = ""

@Serializable
enum class Command(val key: String) {
    CALL("call"),
    HANGUP("hangup")
}
@Serializable
data class CommonRequest(
    val cmd: String
)

@Serializable
data class CallRequest(
    val number: String
)

class DeviceActivity : AppCompatActivity() {

    companion object {
        fun getIntent(context: Context, device: IQDevice?): Intent {
            val intent = Intent(context, DeviceActivity::class.java)
            intent.putExtra(EXTRA_IQ_DEVICE, device)
            return intent
        }
    }

    private var deviceStatusView: TextView? = null
    private var openAppButtonView: TextView? = null

    private val connectIQ: ConnectIQ = ConnectIQ.getInstance()
    private lateinit var device: IQDevice

    private var appIsOpen = false
    private val openAppListener = ConnectIQ.IQOpenApplicationListener { _, _, status ->
        Toast.makeText(applicationContext, "App Status: " + status.name, Toast.LENGTH_SHORT).show()

        if (status == ConnectIQ.IQOpenApplicationStatus.APP_IS_ALREADY_RUNNING) {
            appIsOpen = true
            openAppButtonView?.setText(R.string.open_app_already_open)
        } else {
            appIsOpen = false
            openAppButtonView?.setText(R.string.open_app_open)
        }
    }

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_device)

        device = intent.getParcelableExtra<Parcelable>(EXTRA_IQ_DEVICE) as IQDevice
        appIsOpen = false

        val deviceNameView = findViewById<TextView>(R.id.devicename)
        deviceStatusView = findViewById(R.id.devicestatus)
        openAppButtonView = findViewById(R.id.openapp)
        val openAppStoreView = findViewById<View>(R.id.openstore)

        deviceNameView?.text = device.friendlyName
        deviceStatusView?.text = device.status?.name
        openAppButtonView?.setOnClickListener { openMyApp() }
        openAppStoreView?.setOnClickListener { openStore() }

        listenByDeviceEvents()
        listenByMyAppEvents()
        getMyAppStatus()

        val contactsJsonObject = ContactsRepository(this).contactsJsonObject()
        val msg = mapOf(
            "cmd" to "setPhones",
            "phones" to contactsJsonObject
        )
        globalLifecycleCoroutineScope = lifecycleScope
        send(msg, this, lifecycleScope, connectIQ, device, myApp)
    }

    public override fun onResume() {
        super.onResume()
        return

        listenByDeviceEvents()
        listenByMyAppEvents()
        getMyAppStatus()
    }

    public override fun onPause() {
        super.onPause()
        return
        
        // It is a good idea to unregister everything and shut things down to
        // release resources and prevent unwanted callbacks.
        try {
            connectIQ.unregisterForDeviceEvents(device)
            connectIQ.unregisterForApplicationEvents(device, myApp)
        } catch (_: InvalidStateException) {
        }
    }

    private fun openMyApp() {
        Toast.makeText(this, "Opening app...", Toast.LENGTH_SHORT).show()

        // Send a message to open the app
        try {
            connectIQ.openApplication(device, myApp, openAppListener)
        } catch (_: Exception) {
        }
    }

    private fun openStore() {
        Toast.makeText(this, "Opening ConnectIQ Store...", Toast.LENGTH_SHORT).show()

        // Send a message to open the store
        try {
            if (STORE_APP_ID.isBlank()) {
                AlertDialog.Builder(this@DeviceActivity)
                    .setTitle(R.string.missing_store_id)
                    .setMessage(R.string.missing_store_id_message)
                    .setPositiveButton(android.R.string.ok, null)
                    .create()
                    .show()
            } else {
                connectIQ.openStore(STORE_APP_ID)
            }
        } catch (_: Exception) {
        }
    }

    private fun listenByDeviceEvents() {
        // Get our instance of ConnectIQ. Since we initialized it
        // in our MainActivity, there is no need to do so here, we
        // can just get a reference to the one and only instance.
        try {
            lifecycleScope.launch {
                withContext(Dispatchers.IO) {
                    connectIQ.registerForDeviceEvents(device) { _, status ->
                        // Since we will only get updates for this device, just display the status
                        deviceStatusView?.text = status.name
                    }
                }
            }
        } catch (e: InvalidStateException) {
            Log.wtf(TAG, "InvalidStateException:  We should not be here!")
        }
    }

    // Let's register to receive messages from our application on the device.
    private fun listenByMyAppEvents() {
        try {
            connectIQ.registerForAppEvents(device, myApp) { _, _, message, _ ->
                for (o in message) {
                    val pojo = o as Map<String, Any>
                    val string = JSONObject(o).toString()
                    val Json = Json { ignoreUnknownKeys = true }
                    val obj = Json.decodeFromString<CommonRequest>(string)
                    when (obj.cmd) {
                        "call" -> {
                            val callRequest = Json.decodeFromString<CallRequest>(string)
                            makeCall(callRequest.number)
                        }
                        "hangup" -> {
                            print("HANGUP")
                            hangupCall()
                        }
                    }
                }
            }
        } catch (e: InvalidStateException) {
            Toast.makeText(this, "ConnectIQ is not in a valid state", Toast.LENGTH_SHORT).show()
        }
    }

    private fun makeCall(number: String) {
        val intent = Intent(Intent.ACTION_CALL)
        intent.setData(Uri.parse("tel:${number}"))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_FROM_BACKGROUND)
        if (true) {
            startActivity(intent)
        } else {
            val options = ActivityOptions.makeBasic()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                options.setPendingIntentBackgroundActivityStartMode(ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED)
            }
            val pendingIntent = PendingIntent.getActivity(
                this,
                1,
                intent,
                PendingIntent.FLAG_IMMUTABLE,
                options.toBundle()
            )
            try {
                // Perform the operation associated with our pendingIntent
                pendingIntent.send()
            } catch (e: PendingIntent.CanceledException) {
                e.printStackTrace()
            }
        }
    }

    private fun hangupCall() {
        val mgr = getSystemService(TELECOM_SERVICE) as TelecomManager
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ANSWER_PHONE_CALLS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ANSWER_PHONE_CALLS), 0)
            return
        }
        mgr.endCall()
    }

    // Let's check the status of our application on the device.
    private fun getMyAppStatus() {
        try {
            connectIQ.getApplicationInfo(COMM_WATCH_ID, device, object :
                ConnectIQ.IQApplicationInfoListener {
                override fun onApplicationInfoReceived(app: IQApp) {
                    // This is a good thing. Now we can show our list of message options.
                    buildMessageList()
                }

                override fun onApplicationNotInstalled(applicationId: String) {
                    // The Comm widget is not installed on the device so we have
                    // to let the user know to install it.
                    AlertDialog.Builder(this@DeviceActivity)
                        .setTitle(R.string.missing_widget)
                        .setMessage(R.string.missing_widget_message)
                        .setPositiveButton(android.R.string.ok, null)
                        .create()
                        .show()
                }
            })
        } catch (_: InvalidStateException) {
        } catch (_: ServiceUnavailableException) {
        }
    }

    private fun buildMessageList() {
        val adapter = MessagesAdapter { onItemClick(it) }
        adapter.submitList(MessageFactory.getMessages(this@DeviceActivity))
        findViewById<RecyclerView>(android.R.id.list).apply {
            layoutManager = LinearLayoutManager(this@DeviceActivity)
            this.adapter = adapter
        }
    }

    private fun onItemClick(message: Any) {
        try {
            connectIQ.sendMessage(device, myApp, message) { _, _, status ->
                Toast.makeText(this@DeviceActivity, status.name, Toast.LENGTH_SHORT).show()
            }
        } catch (e: InvalidStateException) {
            Toast.makeText(this, "ConnectIQ is not in a valid state", Toast.LENGTH_SHORT).show()
        } catch (e: ServiceUnavailableException) {
            Toast.makeText(
                this,
                "ConnectIQ service is unavailable.   Is Garmin Connect Mobile installed and running?",
                Toast.LENGTH_LONG
            ).show()
        }
    }
}

fun send(javaObject: Any, context: Context?, lifecycleCoroutineScope: LifecycleCoroutineScope, connectIQ: ConnectIQ, device: IQDevice?, myApp: IQApp) {
    try {
        lifecycleCoroutineScope.launch {
            withContext(Dispatchers.IO) {
                connectIQ.sendMessage(
                    device,
                    myApp,
                    javaObject
                ) { _, _, status ->
                    lifecycleCoroutineScope.launch {
                        Toast.makeText(context, status.name, Toast.LENGTH_SHORT)
                            .show()
                    }
                }
            }
        }
    } catch (e: InvalidStateException) {
        Toast.makeText(context, "ConnectIQ is not in a valid state", Toast.LENGTH_SHORT).show()
    } catch (e: ServiceUnavailableException) {
        Toast.makeText(
            context,
            "ConnectIQ service is unavailable.   Is Garmin Connect Mobile installed and running?",
            Toast.LENGTH_LONG
        ).show()
    }
}