package com.example.roadsos_mobile

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val NATIVE_CHANNEL = "com.roadsos.mobile/native"
    private val SMS_CHANNEL = "automatic_sms/sms"
    private val NOTIFICATION_PERMISSION_CODE = 102
    private val ALL_MANDATORY_PERMISSIONS_CODE = 105
    private val SMS_PERMISSION_REQUEST = 1001

    private var pendingPhoneNumber: String? = null
    private var pendingMessage: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Request all mandatory hardware permissions on startup
        requestMandatoryPermissions()

        // 1. Native Sensors, Ride Mode & Vibration Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentGpsLocation" -> {
                    fetchGpsLocation(result)
                }
                "triggerCrashVibration" -> {
                    try {
                        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as android.os.Vibrator
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val timings = longArrayOf(0, 800, 200, 800, 200, 800)
                            val amplitudes = intArrayOf(0, 255, 0, 255, 0, 255)
                            vibrator.vibrate(android.os.VibrationEffect.createWaveform(timings, amplitudes, -1))
                        } else {
                            @Suppress("DEPRECATION")
                            vibrator.vibrate(longArrayOf(0, 800, 200, 800, 200, 800), -1)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("VIBRATE_FAILED", e.localizedMessage, null)
                    }
                }
                "startRideModeService" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= 33) {
                            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_CODE)
                            }
                        }
                        val intent = Intent(this, RideModeService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_FAILED", e.localizedMessage, null)
                    }
                }
                "stopRideModeService" -> {
                    try {
                        val intent = Intent(this, RideModeService::class.java)
                        stopService(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_FAILED", e.localizedMessage, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 2. Automatic SMS Telephony Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber.isNullOrBlank()) {
                        result.error("INVALID_NUMBER", "Phone number is empty.", null)
                        return@setMethodCallHandler
                    }

                    if (message.isNullOrBlank()) {
                        result.error("INVALID_MESSAGE", "SMS message is empty.", null)
                        return@setMethodCallHandler
                    }

                    sendSms(phoneNumber, message, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendSms(phoneNumber: String, message: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            pendingPhoneNumber = phoneNumber
            pendingMessage = message
            pendingResult = result

            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.SEND_SMS),
                SMS_PERMISSION_REQUEST
            )
            return
        }

        sendSmsNow(phoneNumber, message, result)
    }

    private fun sendSmsNow(phoneNumber: String, message: String, result: MethodChannel.Result) {
        try {
            val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }

            val parts = smsManager.divideMessage(message)
            if (parts.size == 1) {
                smsManager.sendTextMessage(phoneNumber, null, message, null, null)
            } else {
                smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
            }

            result.success("SMS sent successfully.")
        } catch (e: SecurityException) {
            result.error("SMS_PERMISSION", "SMS permission was denied.", null)
        } catch (e: Exception) {
            result.error("SMS_ERROR", e.message ?: "Unknown SMS error.", null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == SMS_PERMISSION_REQUEST) {
            val phone = pendingPhoneNumber
            val message = pendingMessage
            val result = pendingResult

            pendingPhoneNumber = null
            pendingMessage = null
            pendingResult = null

            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (phone != null && message != null && result != null) {
                    sendSmsNow(phone, message, result)
                }
            } else {
                result?.error("SMS_PERMISSION_DENIED", "SEND_SMS permission was denied.", null)
            }
        }
    }

    private fun requestMandatoryPermissions() {
        val permissionsToRequest = mutableListOf<String>()

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        if (Build.VERSION.SDK_INT >= 31) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.BLUETOOTH_SCAN)
            }
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.BLUETOOTH_CONNECT)
            }
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_ADVERTISE) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.BLUETOOTH_ADVERTISE)
            }
        }
        if (Build.VERSION.SDK_INT >= 33) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }

        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), ALL_MANDATORY_PERMISSIONS_CODE)
        }
    }

    private fun fetchGpsLocation(result: MethodChannel.Result) {
        val fineGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED

        if (!fineGranted && !coarseGranted) {
            result.success(mapOf("latitude" to 13.0067, "longitude" to 80.2206))
            return
        }

        try {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            var bestLocation: Location? = null

            val providers = locationManager.getProviders(true)
            for (provider in providers) {
                val l = locationManager.getLastKnownLocation(provider) ?: continue
                if (bestLocation == null || l.accuracy < bestLocation.accuracy) {
                    bestLocation = l
                }
            }

            if (bestLocation != null) {
                result.success(mapOf("latitude" to bestLocation.latitude, "longitude" to bestLocation.longitude))
            } else {
                result.success(mapOf("latitude" to 13.0067, "longitude" to 80.2206))
            }
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(mapOf("latitude" to 13.0067, "longitude" to 80.2206))
        }
    }
}


