package com.gentin.connectiq.handsfree.globals

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.lifecycle.LifecycleCoroutineScope
import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import com.gentin.connectiq.handsfree.calllogs.CallLogsRepository
import com.gentin.connectiq.handsfree.calllogs.CallLogsRepositoryImpl
import com.gentin.connectiq.handsfree.calllogs.recentsFromCallLog
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
import com.gentin.connectiq.handsfree.impl.audioStatePojo
import com.gentin.connectiq.handsfree.impl.companionInfo
import com.gentin.connectiq.handsfree.impl.companionInfoPojo
import com.gentin.connectiq.handsfree.impl.isLowMemory
import com.gentin.connectiq.handsfree.impl.newSubjectQuery
import com.gentin.connectiq.handsfree.impl.phonesPojo
import com.gentin.connectiq.handsfree.impl.readinessInfo
import com.gentin.connectiq.handsfree.impl.readinessInfoPojo
import com.gentin.connectiq.handsfree.impl.recentsPojo
import com.gentin.connectiq.handsfree.impl.strippedVersionedPojo
import com.gentin.connectiq.handsfree.impl.subjectQueryName
import com.gentin.connectiq.handsfree.impl.subjectQueryVersion
import com.gentin.connectiq.handsfree.notifications.showPongNotification
import com.gentin.connectiq.handsfree.services.fallbackPhoneState
import com.gentin.connectiq.handsfree.services.lastTrackedPhoneState
import com.gentin.connectiq.handsfree.terms.allSubjectNames
import com.gentin.connectiq.handsfree.terms.appConfigSubject
import com.gentin.connectiq.handsfree.terms.audioStateSubject
import com.gentin.connectiq.handsfree.terms.companionInfoSubject
import com.gentin.connectiq.handsfree.terms.phoneStateSubject
import com.gentin.connectiq.handsfree.terms.phonesSubject
import com.gentin.connectiq.handsfree.terms.readinessInfoSubject
import com.gentin.connectiq.handsfree.terms.recentsSubject

private const val separateQueryResults = true

const val recentsLimitLowMemory = 5
const val recentsLimitFullFeatured = 10
const val phonesLimitLowMemory = 10
const val phonesLimitFullFeatured = 20

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
                outgoingMessageDispatcher.sendSyncYouV1(
                    availableContacts().contacts,
                    lastTrackedPhoneState
                )
            },
            syncPhonesV1Imp = { source ->
                val destination = OutgoingMessageDestination(
                    source.device, source.app,
                    accountBroadcastOnly = false
                )
                outgoingMessageDispatcher.sendPhonesV1(destination, availableContacts().contacts)
            },
            queryImp = { source, args ->
                garminConnector.trackFirstAppLaunch(source.device, source.app)
                val destination = OutgoingMessageDestination(
                    source.device,
                    source.app,
                    accountBroadcastOnly = false
                )
                if (separateQueryResults) {
                    for (subject in args.subjects) {
                        val subjectArgs = QueryArgs(listOf(subject))
                        val result = query(subjectArgs, source = source)
                        outgoingMessageDispatcher.sendQueryResult(destination, result)
                    }
                } else {
                    val result = query(args, source = source)
                    outgoingMessageDispatcher.sendQueryResult(destination, result)
                }
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
                trackAudioState(audioState)
            },
            muteImp = { on ->
                audioControl.mute(on)
                trackAudioState(audioState())
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
        val lm = isLowMemory(garminConnector.appConfig(source.device, source.app))
        for (subject in args.subjects) {
            val subjectName = subjectQueryName(subject)
            val subjectVersion = subjectQueryVersion(subject)
            assert(allSubjectNames.contains(subjectName)) { "Unknown subject: $subjectName" }
            when (subjectName) {
                phoneStateSubject -> {
                    queryResult.phoneState = lastTrackedPhoneState ?: fallbackPhoneState()
                }

                appConfigSubject -> {
                    if (metadataOnly) {
                        queryResult.appConfig = garminConnector.appConfig(source.device, source.app)
                    } else {
                        queryResult.appConfig = subjectVersion
                    }
                }

                phonesSubject -> {
                    val limit = if (lm) {
                        phonesLimitLowMemory
                    } else {
                        phonesLimitFullFeatured
                    }
                    queryResult.phones =
                        strippedVersionedPojo(
                            subjectVersion,
                            phonesPojo(availableContacts(), limit),
                            metadataOnly
                        )
                }

                recentsSubject -> {
                    val limit = if (lm) {
                        recentsLimitLowMemory
                    } else {
                        recentsLimitFullFeatured
                    }
                    queryResult.recents =
                        strippedVersionedPojo(
                            subjectVersion,
                            recentsPojo(recents(), limit),
                            metadataOnly
                        )
                }

                audioStateSubject -> {
                    queryResult.audioState =
                        strippedVersionedPojo(
                            subjectVersion,
                            audioStatePojo(audioState()),
                            metadataOnly
                        )
                }

                companionInfoSubject -> {
                    queryResult.companionInfo =
                        strippedVersionedPojo(
                            subjectVersion,
                            companionInfoPojo(companionInfo()),
                            metadataOnly
                        )
                }

                readinessInfoSubject -> {
                    queryResult.readinessInfo =
                        strippedVersionedPojo(
                            subjectVersion,
                            readinessInfoPojo(readinessInfo(context = this)),
                            metadataOnly
                        )
                }

                else -> {
                    Log.e(TAG, "Unknown subject: $subjectName")
                }
            }
        }
        return queryResult
    }

    fun availableContacts(): AvailableContacts {
        if (!starredContactsAreOn(this)) {
            return AvailableContacts(accessIssue = AccessIssue.Disabled)
        }
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            return AvailableContacts(accessIssue = AccessIssue.NoPermission)
        }
        return try {
            AvailableContacts(
                contactsRepository.contactsData()
            )
        } catch (e: RuntimeException) {
            Log.e(TAG, "contactsRetrievalFailed: $e")
            AvailableContacts(
                accessIssue = AccessIssue.ReadFailure
            )
        }
    }

    fun recents(): AvailableRecents {
        if (!recentsAreOn(this)) {
            return AvailableRecents(accessIssue = AccessIssue.Disabled)
        }
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CALL_LOG
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            return AvailableRecents(accessIssue = AccessIssue.NoPermission)
        }
        try {
            val recents = recentsFromCallLog(callLogRepository.callLog())
            return AvailableRecents(recents)
        } catch (e: RuntimeException) {
            return AvailableRecents(accessIssue = AccessIssue.ReadFailure)
        }
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
        if (state.activeAudioDevice == null) {
            // One of the cases when the audio state is changed is when a phone call begins.
            // In that case the active audio device is initially null and soon becomes non-null.
            // To avoid overloading the watch with the messages, we delay sending the audio state.
            // We assume that it's also safe in all other cases, when idle we send the audio state
            // (e.g. tracking headset status) - it's not a big deal to have a delay then.
            val handler = Handler(Looper.getMainLooper())
            handler.postDelayed({
                trackAudioState(audioState())
            }, 1000)
        } else {
            trackAudioState(state)
        }
    }

    private var lastTrackedAudioState: AudioState? = null

    private fun trackAudioState(state: AudioState) {
        if (state == lastTrackedAudioState) {
            Log.d(TAG, "notTrackingUnchangedAudioState: $state")
            return
        }
        Log.d(TAG, "trackingChangedAudioState: $state")
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
            trackAppConfig = { destination, config ->
                garminConnector.trackAppConfig(
                    destination.device!!,
                    destination.app!!,
                    config
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
                        newSubjectQuery(name, null)
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

    val communicationDeviceChangedListener: AudioManager.OnCommunicationDeviceChangedListener by lazy {
        AudioManager.OnCommunicationDeviceChangedListener { device ->
            val deviceInfo = "\"${device?.productName}\" (${device?.type})"
            if (lastTrackedPhoneState?.stateId == PhoneStateId.Idle) {
                Log.d(TAG, "communicationDeviceChangedWhileIdle: $deviceInfo")
                accountAudioState()
            } else {
                Log.d(TAG, "communicationDeviceChangedInCall: $deviceInfo, $lastTrackedPhoneState")
                if (lastTrackedPhoneState?.stateId == PhoneStateId.Ringing) {
                    // This is workaround for watch app considered by Garmin OS as running,
                    // when we try to open it as part of incoming call, as it
                    // handles the updated audio state received in background:
                    // that prevents it from opening automatically.
                    // To avoid getting into that situation, we ignore audio state changes on
                    // ringing, assuming that the state will change again the call is
                    // accepted.
                    Log.d(TAG, "ignoringAudioStateChangeDueToRinging")
                } else {
                    accountAudioState()
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
