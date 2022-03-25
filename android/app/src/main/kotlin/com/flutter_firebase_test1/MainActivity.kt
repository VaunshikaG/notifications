package com.firebase_notify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin

class MainActivity: FlutterActivity() {
}


//class Application: FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
//    override fun onCreate() {
//        super.onCreate()FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this)
//    }
//    override fun registerWith(registry:PluginRegistry) {
//        FlutterFirebaseMessagingPlugin.registerWith(
//                registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
//    }
//}

//  app password for bit bucket
//  TgdHAHEjbXqWhWQhaB2g