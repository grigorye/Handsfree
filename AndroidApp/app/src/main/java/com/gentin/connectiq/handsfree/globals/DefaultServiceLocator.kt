package com.gentin.connectiq.handsfree.globals

import android.content.Context
import android.content.ContextWrapper
import android.media.AudioManager
import android.util.Log
import androidx.lifecycle.LifecycleCoroutineScope
import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import androidx.preference.PreferenceManager
import com.gentin.connectiq.handsfree.calllogs.CallLogEntry
import com.gentin.connectiq.handsfree.calllogs.CallLogsRepository
import com.gentin.connectiq.handsfree.calllogs.CallLogsRepositoryImpl
import com.gentin.connectiq.handsfree.calllogs.recentsFromCallLog
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.contacts.ContactsRepository
import com.gentin.connectiq.handsfree.contacts.ContactsRepositoryImpl
import com.gentin.connectiq.handsfree.contacts.contactsGroupId
import com.gentin.connectiq.handsfree.contacts.forEachContactInGroup
import com.gentin.connectiq.handsfree.contacts.forEachContactWithPhoneNumberInFavorites
import com.gentin.connectiq.handsfree.impl.AudioControl
import com.gentin.connectiq.handsfree.impl.AudioControlImp
import com.gentin.connectiq.handsfree.impl.AudioState
import com.gentin.connectiq.handsfree.impl.DefaultGarminConnector
import com.gentin.connectiq.handsfree.impl.DefaultOutgoingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.DefaultPhoneCallService
import com.gentin.connectiq.handsfree.impl.DeviceInfo
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.HeadsetConnectionMonitor
import com.gentin.connectiq.handsfree.impl.IncomingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.IncomingMessageSource
import com.gentin.connectiq.handsfree.impl.OutgoingMessage
import com.gentin.connectiq.handsfree.impl.OutgoingMessageDestination
import com.gentin.connectiq.handsfree.impl.OutgoingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.PhoneCallService
import com.gentin.connectiq.handsfree.impl.PhoneStateId
import com.gentin.connectiq.handsfree.impl.QueryArgs
import com.gentin.connectiq.handsfree.impl.QueryResult
import com.gentin.connectiq.handsfree.impl.RemoteMessageService
import com.gentin.connectiq.handsfree.impl.SubjectQuery
import com.gentin.connectiq.handsfree.impl.audioStatePojo
import com.gentin.connectiq.handsfree.impl.companionInfo
import com.gentin.connectiq.handsfree.impl.companionInfoPojo
import com.gentin.connectiq.handsfree.impl.phonesPojo
import com.gentin.connectiq.handsfree.impl.recentsPojo
import com.gentin.connectiq.handsfree.impl.strippedVersionedPojo
import com.gentin.connectiq.handsfree.notifications.showPongNotification
import com.gentin.connectiq.handsfree.services.fallbackPhoneState
import com.gentin.connectiq.handsfree.services.lastTrackedAudioState
import com.gentin.connectiq.handsfree.services.lastTrackedPhoneState
import com.gentin.connectiq.handsfree.terms.allSubjectNames
import com.gentin.connectiq.handsfree.terms.audioStateSubject
import com.gentin.connectiq.handsfree.terms.broadcastSubject
import com.gentin.connectiq.handsfree.terms.companionInfoSubject
import com.gentin.connectiq.handsfree.terms.phonesSubject
import com.gentin.connectiq.handsfree.terms.recentsSubject

class DefaultServiceLocator(
    base: Context?,
    lifecycleScope: LifecycleCoroutineScope
) : ContextWrapper(base) {

    private val phoneCallService: PhoneCallService by lazy {
        DefaultPhoneCallService(this)
    }

    private val targetContactsGroupName: String? = null // e.g. "Handsfree", null for Favorites

    val contactsRepository: ContactsRepository by lazy {
        ContactsRepositoryImpl(this) {
            if (targetContactsGroupName != null) {
                val groupId = contactsGroupId(this, targetContactsGroupName)
                if (groupId != null) {
                    forEachContactInGroup(this, groupId, it)
                }
            } else {
                forEachContactWithPhoneNumberInFavorites(this, it)
            }
        }
    }

    val callLogRepository: CallLogsRepository by lazy {
        CallLogsRepositoryImpl(this)
    }

    private val incomingMessageDispatcher: IncomingMessageDispatcher by lazy {
        IncomingMessageDispatcher(
            appVersionImp = { source ->
                garminConnector.appVersion(source.device, source.app)
            },
            makeCallImp = { source, phoneNumber ->
                val withSpeakerPhone = !headPhoneConnectionMonitor.isHeadsetConnected()
                if (!phoneCallService.makeCall(phoneNumber, withSpeakerPhone)) {
                    val destination = OutgoingMessageDestination(
                        source.device, source.app,
                        accountBroadcastOnly = false
                    )
                    outgoingMessageDispatcher.sendPhoneState(
                        destination,
                        lastTrackedPhoneState ?: fallbackPhoneState()
                    )
                }
            },
            hangupCallImp = {
                phoneCallService.hangupCall()
            },
            acceptCallImp = {
                phoneCallService.acceptCall()
            },
            syncV1Imp = {
                outgoingMessageDispatcher.sendSyncYouV1(availableContacts(), lastTrackedPhoneState)
            },
            syncPhonesV1Imp = { source ->
                val destination = OutgoingMessageDestination(
                    source.device, source.app,
                    accountBroadcastOnly = false
                )
                outgoingMessageDispatcher.sendPhonesV1(destination, availableContacts())
            },
            queryImp = { source, args ->
                val destination = OutgoingMessageDestination(
                    source.device,
                    source.app,
                    accountBroadcastOnly = false
                )
                val result = query(args, source = source)
                outgoingMessageDispatcher.sendQueryResult(destination, result)
            },
            openAppImp = { source, args ->
                if (lastTrackedPhoneState?.stateId != PhoneStateId.Ringing) {
                    Log.d(
                        TAG,
                        "ignoringOpenAppDueToNotRinging: ${lastTrackedPhoneState?.stateId}"
                    )
                } else {
                    garminConnector.openWatchAppOnDevice(source.device, source.app) { succeeded ->
                        val destination = OutgoingMessageDestination(source.device, source.app)
                        outgoingMessageDispatcher.sendOpenMeCompleted(destination, args, succeeded)
                    }
                }
            },
            didFirstLaunchImp = { source ->
                garminConnector.trackFirstAppLaunch(source.device, source.app)
                val subjects = allSubjectNames.map { name ->
                    SubjectQuery(name = name, version = null)
                }
                val args = QueryArgs(subjects)
                val result = query(args, source = source)
                val destination = OutgoingMessageDestination(source.device, source.app)
                outgoingMessageDispatcher.sendQueryResult(destination, result)
            },
            openAppInStoreImp = { source ->
                garminConnector.openWatchAppInStore(source.app)
            },
            toggleSpeakerImp = {
                audioControl.toggleSpeaker(true)
            },
            setAudioVolumeImp = { relVolume ->
                audioControl.setAudioVolume(relVolume)
                val audioState = audioState()
                audioState.volume = relVolume
                outgoingMessageDispatcher.sendAudioState(audioState)
            },
            muteImp = { on ->
                audioControl.mute(on)
                outgoingMessageDispatcher.sendAudioState(audioState())
            },
            pongImp = { source ->
                Log.d(TAG, "Pong: $source")
                showPongNotification(this, source)
            }
        )
    }

    private fun query(
        args: QueryArgs,
        metadataOnly: Boolean = false,
        source: IncomingMessageSource
    ): QueryResult {
        val queryResult = QueryResult()
        for (subject in args.subjects) {
            assert(allSubjectNames.contains(subject.name)) { "Unknown subject: ${subject.name}" }
            when (subject.name) {
                broadcastSubject -> {
                    if (metadataOnly) {
                        queryResult.broadcastEnabled =
                            garminConnector.isAppListeningForBroadcasts(source.device, source.app)
                    } else {
                        queryResult.broadcastEnabled = subject.version == 1
                    }
                }

                phonesSubject -> {
                    queryResult.phones =
                        strippedVersionedPojo(
                            subject.version,
                            phonesPojo(availableContacts()),
                            metadataOnly
                        )
                }

                recentsSubject -> {
                    queryResult.recents =
                        strippedVersionedPojo(subject.version, recentsPojo(recents()), metadataOnly)
                }

                audioStateSubject -> {
                    queryResult.audioState =
                        strippedVersionedPojo(
                            subject.version,
                            audioStatePojo(audioState()),
                            metadataOnly
                        )
                }

                companionInfoSubject -> {
                    queryResult.companionInfo =
                        strippedVersionedPojo(
                            subject.version,
                            companionInfoPojo(companionInfo()),
                            metadataOnly
                        )
                }

                else -> {
                    Log.e(TAG, "Unknown subject: ${subject.name}")
                }
            }
        }
        return queryResult
    }

    fun availableContacts(): List<ContactData> {
        return try {
            contactsRepository.contacts()
        } catch (e: RuntimeException) {
            Log.e(TAG, "contactsRetrievalFailed: $e")
            listOf()
        }
    }

    private fun callLog(): List<CallLogEntry> {
        return try {
            callLogRepository.callLog()
        } catch (e: RuntimeException) {
            Log.e(TAG, "callLogRetrievalFailed: $e")
            listOf()
        }
    }

    private fun isRecentsEnabled(): Boolean {
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        return sharedPreferences.getBoolean("recents", false)
    }

    fun recents(): List<CallLogEntry> {
        if (!isRecentsEnabled()) {
            return listOf()
        }
        return recentsFromCallLog(callLog())
    }

    private fun audioState(): AudioState {
        val isHeadsetConnected = headPhoneConnectionMonitor.isHeadsetConnected()
        val state = AudioState(
            isHeadsetConnected,
            activeAudioDevice = audioControl.activeAudioDevice(),
            isMuted = audioControl.isMuted(),
            volume = audioControl.audioVolume()
        )
        return state
    }

    val headPhoneConnectionMonitor = HeadsetConnectionMonitor(this) {
        sendHeadsetState()
    }

    private fun sendHeadsetState() {
        accountAudioState()
    }

    fun accountAudioState() {
        val state = audioState()
        lastTrackedAudioState = state
        outgoingMessageDispatcher.sendAudioState(state)
    }

    private val remoteMessageService: RemoteMessageService by lazy {

        class CompoundRemoteMessageService : RemoteMessageService {
            override fun sendMessage(message: OutgoingMessage) {
                garminConnector.sendMessage(message)
            }
        }
        CompoundRemoteMessageService()
    }

    val outgoingMessageDispatcher: OutgoingMessageDispatcher by lazy {
        DefaultOutgoingMessageDispatcher(
            this,
            remoteMessageService,
            trackAppListeningForBroadcast = { destination, enabled ->
                garminConnector.trackAppListeningForBroadcasts(
                    destination.device!!,
                    destination.app!!,
                    enabled
                )
            }
        )
    }

    private val audioControl: AudioControl by lazy {
        AudioControlImp(this)
    }

    val garminConnector: GarminConnector by lazy {
        DefaultGarminConnector(
            this,
            lifecycleScope = lifecycleScope,
            dispatchIncomingMessage = { o, source ->
                incomingMessageDispatcher.handleMessage(o, source)
            },
            appDataMayBeInvalidated = { device, app ->
                val appVersion = activeGarminConnector.value?.appVersion(device, app) ?: 0
                if (appVersion == 1) {
                    Log.d(
                        TAG,
                        "ignoringAppDataInvalidationDueToV1: $device, ${appLogName(app)}($appVersion)"
                    )
                } else {
                    val subjects = allSubjectNames.map { name ->
                        SubjectQuery(name = name, version = null)
                    }
                    val args = QueryArgs(subjects)
                    val source = IncomingMessageSource(device, app)
                    val result = query(args, metadataOnly = true, source = source)
                    val destination = OutgoingMessageDestination(device, app)
                    outgoingMessageDispatcher.sendQueryResult(destination, result)
                }
            }
        ).apply {
            activeGarminConnector.value = this
        }
    }

    private var lastObservedAudioState: AudioState? = null

    val communicationDeviceChangedListener: AudioManager.OnCommunicationDeviceChangedListener by lazy {
        AudioManager.OnCommunicationDeviceChangedListener { device ->
            val deviceInfo = "\"${device?.productName}\" (${device?.type})"
            if (lastTrackedPhoneState?.stateId == PhoneStateId.Idle) {
                Log.d(TAG, "communicationDeviceChangedWhileIdle: $deviceInfo")
                lastObservedAudioState = null
            } else {
                Log.d(TAG, "communicationDeviceChangedInCall: $deviceInfo, $lastTrackedPhoneState")
                val audioState = audioState()
                if (lastObservedAudioState == audioState) {
                    Log.d(TAG, "audioStateDidNotChange: $audioState")
                } else {
                    Log.d(TAG, "audioStateChanged: $audioState")
                    outgoingMessageDispatcher.sendAudioState(audioState)
                    lastObservedAudioState = audioState
                }
            }
        }
    }

    val audioManager by lazy { getSystemService(AUDIO_SERVICE) as AudioManager }

    companion object {
        private val TAG: String = DefaultServiceLocator::class.java.simpleName
        private val activeGarminConnector = MutableLiveData<GarminConnector>()
        val knownDeviceInfos: LiveData<List<DeviceInfo>> =
            MediatorLiveData<List<DeviceInfo>>().apply {
                addSource(activeGarminConnector) { garminConnector ->
                    addSource(garminConnector.knownDeviceInfos) {
                        value = it
                    }
                }
            }
    }
}
