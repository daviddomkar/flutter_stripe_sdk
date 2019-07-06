package io.dexdev.flutter_stripe_sdk

import android.app.Activity
import com.stripe.android.CustomerSession
import com.stripe.android.EphemeralKeyUpdateListener
import com.stripe.android.Stripe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterStripeSDKPlugin(private val activity: Activity, private val methodChannel: MethodChannel): MethodCallHandler {

  private lateinit var stripe: Stripe

  private var keyUpdateListener: EphemeralKeyUpdateListener? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_stripe_sdk")
      channel.setMethodCallHandler(FlutterStripeSDKPlugin(registrar.activity(), channel))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "init" -> {
        init(call.argument("publishableKey")!!)
        result.success(null)
      }
      "initCustomerSession" -> {
        initCustomerSession()
        result.success(null)
      }
      "onKeyUpdate" -> {
        keyUpdateListener?.onKeyUpdate(call.argument("stripeResponseJson")!!)

        result.success(null)
      }
      "onKeyUpdateFailure" -> {
        keyUpdateListener?.onKeyUpdateFailure(call.argument("responseCode")!!, call.argument("message")!!)

        result.success(null)
      }
      "endCustomerSession" -> {
        endCustomerSession()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun init(publishableKey: String) {
    stripe = Stripe(activity, publishableKey)
  }

  private fun initCustomerSession() {
    CustomerSession.initCustomerSession(activity) { apiVersion: String, keyUpdateListener: EphemeralKeyUpdateListener ->
      this.keyUpdateListener = keyUpdateListener
      methodChannel.invokeMethod("createEphemeralKey", mapOf("apiVersion" to apiVersion))
    }
  }

  private fun endCustomerSession() {
    CustomerSession.endCustomerSession()
  }
}
