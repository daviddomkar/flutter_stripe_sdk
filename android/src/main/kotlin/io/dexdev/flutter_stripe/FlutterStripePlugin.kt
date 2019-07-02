package io.dexdev.flutter_stripe

import android.app.Activity
import com.stripe.android.PaymentConfiguration
import com.stripe.android.Stripe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterStripePlugin(private val activity: Activity): MethodCallHandler {

  private lateinit var stripe: Stripe

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_stripe")
      channel.setMethodCallHandler(FlutterStripePlugin(registrar.activity()))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "init") {
      init(call.argument<String>("publishableKey")!!)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  private fun init(publishableKey: String) {
    PaymentConfiguration.init(publishableKey)
    stripe = Stripe(activity, PaymentConfiguration.getInstance().publishableKey)
  }


}
