package com.gentin.connectiq.handsfree.impl

import android.util.Log
import com.gentin.connectiq.handsfree.globals.simApp
import com.gentin.connectiq.handsfree.terms.acceptInCmd
import com.gentin.connectiq.handsfree.terms.acceptV1InCmd
import com.gentin.connectiq.handsfree.terms.callInCmd
import com.gentin.connectiq.handsfree.terms.callV1InCmd
import com.gentin.connectiq.handsfree.terms.didFirstLaunchInCmd
import com.gentin.connectiq.handsfree.terms.hangUpInCmd
import com.gentin.connectiq.handsfree.terms.hangUpV1InCmd
import com.gentin.connectiq.handsfree.terms.muteInCmd
import com.gentin.connectiq.handsfree.terms.openAppInStoreInCmd
import com.gentin.connectiq.handsfree.terms.openMeInCmd
import com.gentin.connectiq.handsfree.terms.queryInCmd
import com.gentin.connectiq.handsfree.terms.setAudioVolumeInCmd
import com.gentin.connectiq.handsfree.terms.syncMeV1InCmd
import com.gentin.connectiq.handsfree.terms.syncPhonesV1InCmd
import com.gentin.connectiq.handsfree.terms.toggleSpeakerInCmd
import kotlinx.serialization.json.Json
import org.json.JSONObject

class IncomingMessageDispatcher(
    private val appVersionImp: (source: IncomingMessageSource) -> Int?,
    private val makeCallImp: (source: IncomingMessageSource, phoneNumber: String) -> Unit,
    private val hangupCallImp: () -> Unit,
    private val acceptCallImp: () -> Unit,
    private val queryImp: (source: IncomingMessageSource, args: QueryArgs) -> Unit,
    private val syncV1Imp: () -> Unit,
    private val syncPhonesV1Imp: (destination: IncomingMessageSource) -> Unit,
    private val didFirstLaunchImp: (destination: IncomingMessageSource) -> Unit,
    private val openAppImp: (source: IncomingMessageSource, args: OpenMeArgs) -> Unit,
    private val openAppInStoreImp: (source: IncomingMessageSource) -> Unit,
    private val toggleSpeakerImp: () -> Unit,
    private val setAudioVolumeImp: (RelVolume) -> Unit,
    private val muteImp: (Boolean) -> Unit
) {
    fun handleMessage(message: Any, source: IncomingMessageSource) {
        val pojo = message as Map<*, *>
        val string = JSONObject(pojo).toString()
        Log.d(TAG, "incomingMsg: $string, source: $source")
        val json = Json { ignoreUnknownKeys = true }
        val obj = json.decodeFromString<CommonRequest>(string)
        simulateCommDelay(source)
        when (obj.cmd) {
            callV1InCmd -> {
                val callRequest = json.decodeFromString<CallRequestV1>(string)
                Log.d(TAG, "callRequest: $callRequest")
                makeCallImp(source, callRequest.args.number)
            }

            callInCmd -> {
                val callRequest = json.decodeFromString<CallRequest>(string)
                Log.d(TAG, "callRequest: $callRequest")
                makeCallImp(source, callRequest.args.number)
            }

            hangUpV1InCmd -> {
                hangupCallImp()
            }

            hangUpInCmd -> {
                hangupCallImp()
            }

            acceptV1InCmd -> {
                acceptCallImp()
            }

            acceptInCmd -> {
                acceptCallImp()
            }

            syncMeV1InCmd -> {
                assert(appVersionImp(source) == 1, { "wrongAppVersion: ${appVersionImp(source)}" })
                syncV1Imp()
            }

            syncPhonesV1InCmd -> {
                assert(appVersionImp(source) == 1, { "wrongAppVersion: ${appVersionImp(source)}" })
                syncPhonesV1Imp(source)
            }

            queryInCmd -> {
                val queryRequest = json.decodeFromString<QueryRequest>(string)
                Log.d(TAG, "callRequest: $queryRequest")
                queryImp(source, queryRequest.args)
            }

            openMeInCmd -> {
                val openMeRequest = json.decodeFromString<OpenMeRequest>(string)
                Log.d(TAG, "openMeRequest: $openMeRequest")
                openAppImp(source, openMeRequest.args)
            }

            openAppInStoreInCmd -> {
                openAppInStoreImp(source)
            }

            didFirstLaunchInCmd -> {
                didFirstLaunchImp(source)
            }

            toggleSpeakerInCmd -> {
                toggleSpeakerImp()
            }

            setAudioVolumeInCmd -> {
                val request = json.decodeFromString<SetAudioVolumeRequest>(string)
                Log.d(TAG, "setAudioVolumeRequest: $request")
                setAudioVolumeImp(request.args.volume)
            }

            muteInCmd -> {
                val request = json.decodeFromString<MuteRequest>(string)
                Log.d(TAG, "muteRequest: $request")
                muteImp(request.args.on)
            }

            else -> {
                Log.e(TAG, "unknownMsg: $string")
            }
        }
    }

    private fun simulateCommDelay(source: IncomingMessageSource) {
        if (commDelaySimulationEnabled(source)) {
            Thread.sleep(5000)
        }
    }

    private fun commDelaySimulationEnabled(source: IncomingMessageSource): Boolean {
        return source.app == simApp
    }

    companion object {
        private val TAG: String = IncomingMessageDispatcher::class.java.simpleName
    }
}