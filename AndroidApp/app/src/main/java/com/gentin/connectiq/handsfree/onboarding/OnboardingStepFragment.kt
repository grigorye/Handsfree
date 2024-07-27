package com.gentin.connectiq.handsfree.onboarding

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.util.Log
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
import io.noties.markwon.html.HtmlPlugin
import io.noties.markwon.image.ImagesPlugin
import io.noties.markwon.image.destination.ImageDestinationProcessorAssets
import io.noties.markwon.image.file.FileSchemeHandler
import io.noties.markwon.image.svg.SvgMediaDecoder


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
            markwon?.setMarkdown(this, preprocessedMarkdown)
            movementMethod = LinkMovementMethod.getInstance()
        }
    }

    fun reloadMarkdown() {
        view?.findViewById<TextView>(R.id.text_view)?.apply {
            markwon?.setMarkdown(this, preprocessedMarkdown)
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

    private val args: OnboardingStepFragmentArgs by navArgs()

    private val markwon by lazy {
        activity?.let {
            Markwon.builder(it)
                .usePlugin(object : AbstractMarkwonPlugin() {
                    override fun configureConfiguration(builder: MarkwonConfiguration.Builder) {
                        builder.apply {
                            imageDestinationProcessor(ImageDestinationProcessorAssets())
                            linkResolver { _, link ->
                                resolveLink(link, this@OnboardingStepFragment)
                            }
                        }
                    }
                })
                .usePlugin(ImagesPlugin.create { plugin ->
                    plugin.addSchemeHandler(FileSchemeHandler.createWithAssets(it))
                    plugin.addMediaDecoder(SvgMediaDecoder.create(it.resources))
                    plugin.errorHandler { url, throwable ->
                        Log.e(TAG, "imagesPluginError: $throwable, url: $url")
                        null
                    }
                })
                .usePlugin(HtmlPlugin.create())
                .build()
        }
    }

    companion object {
        private val TAG: String = OnboardingStepFragment::class.java.simpleName
    }
}
