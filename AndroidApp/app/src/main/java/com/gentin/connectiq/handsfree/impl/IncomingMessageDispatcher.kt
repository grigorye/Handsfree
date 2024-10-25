package com.gentin.connectiq.handsfree.impl

import android.util.Log
import com.gentin.connectiq.handsfree.globals.simApp
import kotlinx.serialization.json.Json
import org.json.JSONObject

private const val muteCmd = "mute"
private const val setAudioVolumeCmd = "setAudioVolume"

class IncomingMessageDispatcher(
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
            "call" -> {
                val callRequest = json.decodeFromString<CallRequest>(string)
                Log.d(TAG, "callRequest: $callRequest")
                makeCallImp(source, callRequest.args.number)
            }

            "hangup" -> {
                hangupCallImp()
            }

            "accept" -> {
                acceptCallImp()
            }

            "syncMe" -> {
                assert(source.app.version() == 1)
                syncV1Imp()
            }

            "syncPhones" -> {
                assert(source.app.version() == 1)
                syncPhonesV1Imp(source)
            }

            "query" -> {
                val queryRequest = json.decodeFromString<QueryRequest>(string)
                Log.d(TAG, "callRequest: $queryRequest")
                queryImp(source, queryRequest.args)
            }

            "openMe" -> {
                val openMeRequest = json.decodeFromString<OpenMeRequest>(string)
                Log.d(TAG, "openMeRequest: $openMeRequest")
                openAppImp(source, openMeRequest.args)
            }

            "openAppInStore" -> {
                openAppInStoreImp(source)
            }

            "didFirstLaunch" -> {
                didFirstLaunchImp(source)
            }

            "toggleSpeaker" -> {
                toggleSpeakerImp()
            }

            setAudioVolumeCmd -> {
                val request = json.decodeFromString<SetAudioVolumeRequest>(string)
                Log.d(TAG, "setAudioVolumeRequest: $request")
                setAudioVolumeImp(request.args.volume)
            }

            muteCmd -> {
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