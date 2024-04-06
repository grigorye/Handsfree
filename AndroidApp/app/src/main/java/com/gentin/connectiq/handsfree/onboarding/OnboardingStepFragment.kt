package com.gentin.connectiq.handsfree.onboarding

import android.os.Bundle
import android.text.Spanned
import android.text.method.LinkMovementMethod
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.navArgs
import com.gentin.connectiq.handsfree.R
import io.noties.markwon.AbstractMarkwonPlugin
import io.noties.markwon.Markwon
import io.noties.markwon.MarkwonConfiguration


open class OnboardingStepFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_onboarding_step, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        view.findViewById<TextView>(R.id.text_view)?.apply {
            text = markdown
            movementMethod = LinkMovementMethod.getInstance()
        }
    }

    fun reloadMarkdown() {
        view?.findViewById<TextView>(R.id.text_view)?.apply {
            text = markdown
        }
    }

    protected val unprocessedMarkdown: String by lazy {
        val resource = args.markdown
        val raw = getString(resource)
        raw
    }

    open val preprocessedMarkdown: String
        get() {
            return preprocessMarkdown(requireActivity(), unprocessedMarkdown)
        }

    private val markdown: Spanned?
        get() {
            return markwon?.toMarkdown(preprocessedMarkdown)
        }

    private val args: OnboardingStepFragmentArgs by navArgs()

    private val markwon by lazy {
        activity?.let {
            Markwon.builder(it)
                .usePlugin(object : AbstractMarkwonPlugin() {
                    override fun configureConfiguration(builder: MarkwonConfiguration.Builder) {
                        builder.linkResolver { _, link ->
                            resolveLink(link, this@OnboardingStepFragment)
                        }
                    }
                })
                .build()
        }
    }

    companion object {
        private val TAG = OnboardingStepFragment::class.java.simpleName
    }
}
