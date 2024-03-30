package com.gentin.connectiq.handsfree.activities

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.navigation.NavOptions
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.databinding.ActivityOnboardingBinding
import com.gentin.connectiq.handsfree.onboarding.OnboardingStepFragment

class OnboardingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityOnboardingBinding

    private val appBarConfiguration = AppBarConfiguration(
        setOf(
            R.id.onboarding_home,
            R.id.overview_home
        )
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate")
        super.onCreate(savedInstanceState)

        binding = ActivityOnboardingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val toolbar = findViewById<Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)

        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        val navController = navHostFragment.navController

        setupActionBarWithNavController(navController, appBarConfiguration)

        val navBarView = binding.navBarView
        navBarView.setupWithNavController(navController)
    }

    public override fun onPause() {
        Log.d(TAG, "onPause")
        super.onPause()
    }

    public override fun onResume() {
        Log.d(TAG, "onResume")
        super.onResume()

        val navHostFragment = supportFragmentManager.findFragmentById(R.id.nav_host_fragment)

        for (childFragment in navHostFragment?.childFragmentManager?.fragments ?: listOf()) {
            (childFragment as? OnboardingStepFragment)?.reloadMarkdown()
        }
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