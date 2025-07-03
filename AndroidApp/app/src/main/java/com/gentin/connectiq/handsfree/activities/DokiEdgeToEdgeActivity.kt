package com.gentin.connectiq.handsfree.activities

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.core.view.updatePadding
import dev.doubledot.doki.api.extensions.DONT_KILL_MY_APP_DEFAULT_MANUFACTURER
import dev.doubledot.doki.api.tasks.DokiApi
import dev.doubledot.doki.views.DokiContentView

// Literally duplicated from DokiActivity, except for the window insets adjustment
class DokiEdgeToEdgeActivity : AppCompatActivity() {

    var api: DokiApi? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val dokiView = DokiContentView(context = this)

        ViewCompat.setOnApplyWindowInsetsListener(dokiView) { v, windowInsets ->
            val insets =
                windowInsets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            v.updatePadding(
                top = insets.top,
                bottom = insets.bottom,
                left = insets.left,
                right = insets.right
            )
            WindowInsetsCompat.CONSUMED
        }

        setContentView(dokiView)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars =
                true
        }

        val manufacturerIdFromIntent = intent.getStringExtra(MANUFACTURER_EXTRA)
        api = dokiView.loadContent(
            manufacturerId = manufacturerIdFromIntent ?: DONT_KILL_MY_APP_DEFAULT_MANUFACTURER
        )

        dokiView.setOnCloseListener { finish() }
    }

    override fun onDestroy() {
        super.onDestroy()
        api?.cancel()
    }

    companion object {

        const val MANUFACTURER_EXTRA =
            "dev.doubledot.doki.ui.DokiActivity.MANUFACTURER_EXTRA"

        @JvmOverloads
        fun newIntent(
            context: Context,
            manufacturerId: String = DONT_KILL_MY_APP_DEFAULT_MANUFACTURER
        ): Intent {
            val intent = Intent(context, DokiEdgeToEdgeActivity::class.java)
            intent.putExtra(MANUFACTURER_EXTRA, manufacturerId)
            return intent
        }

        @JvmOverloads
        fun start(
            context: Context,
            manufacturerId: String = DONT_KILL_MY_APP_DEFAULT_MANUFACTURER
        ) {
            context.startActivity(newIntent(context, manufacturerId))
        }
    }

}