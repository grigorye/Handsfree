package com.gentin.connectiq.handsfree.activities

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.app.ActivityCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.databinding.ActivityOnboardingBinding
import com.gentin.connectiq.handsfree.helpers.REQUEST_CODE_SHARE_LOG
import com.gentin.connectiq.handsfree.helpers.saveLog
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.gentin.connectiq.handsfree.impl.startConnector
import com.gentin.connectiq.handsfree.onboarding.OnboardingStepFragment

class OnboardingActivity : AppCompatActivity(), ActivityCompat.OnRequestPermissionsResultCallback {

    private lateinit var binding: ActivityOnboardingBinding

    private val appBarConfiguration = AppBarConfiguration(
        setOf(
            R.id.onboarding_home,
            R.id.overview_home,
            R.id.settings_home
        )
    )

    override fun onActivityResult(
        requestCode: Int, resultCode: Int, resultData: Intent?) {
        super.onActivityResult(requestCode, resultCode, resultData)
        if (requestCode == REQUEST_CODE_SHARE_LOG && resultCode == RESULT_OK) {
            resultData?.data?.also { uri ->
                saveLog(this, uri)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate")
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        binding = ActivityOnboardingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val toolbar = findViewById<Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)

        ViewCompat.setOnApplyWindowInsetsListener(toolbar) { v, windowInsets ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            v.updatePadding(top = insets.top, left = insets.left, right = insets.right)
            WindowInsetsCompat.CONSUMED
        }

        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        val navController = navHostFragment.navController

        ViewCompat.setOnApplyWindowInsetsListener(binding.navHostFragment) { v, windowInsets ->
            val insets =
                windowInsets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            v.updatePadding(left = insets.left, right = insets.right)
            WindowInsetsCompat.CONSUMED
        }

        setupActionBarWithNavController(navController, appBarConfiguration)

        val navBarView = binding.navBarView
        navBarView.setupWithNavController(navController)

        navController.addOnDestinationChangedListener { _, destination, _ ->
            Log.d(TAG, "navDestinationChanged: $destination")

            binding.navBarView.visibility = if (destination.id == R.id.inner_onboarding_step) {
                View.GONE
            } else {
                View.VISIBLE
            }
        }
    }

    public override fun onPause() {
        Log.d(TAG, "onPause")
        super.onPause()
    }

    public override fun onResume() {
        Log.d(TAG, "onResume")
        startConnector(this, ACTIVATE_FROM_MAIN_ACTIVITY_ACTION)
        super.onResume()

        val navHostFragment = supportFragmentManager.findFragmentById(R.id.nav_host_fragment)

        for (childFragment in navHostFragment?.childFragmentManager?.fragments ?: listOf()) {
            (childFragment as? OnboardingStepFragment)?.reloadMarkdown()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        Log.d(
            TAG,
            "permissions: ${permissions.joinToString(", ")}, grantResults: ${
                grantResults.joinToString(", ")
            }"
        )

        invalidatePermissions(this, permissions, grantResults)
    }

    override fun onSupportNavigateUp(): Boolean {
        return findNavController(R.id.nav_host_fragment).navigateUp(
            appBarConfiguration
        )
    }

    companion object {
        private val TAG = OnboardingActivity::class.java.simpleName
    }
}