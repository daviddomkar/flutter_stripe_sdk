package io.dexdev.flutter_stripe_sdk

import android.app.Activity
import android.util.Log
import com.stripe.android.*
import com.stripe.android.model.Card
import com.stripe.android.model.Customer
import com.stripe.android.model.PaymentMethod
import com.stripe.android.model.PaymentMethodCreateParams
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.Exception

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
      "retrieveCurrentCustomer" -> {
        retrieveCurrentCustomer(result)
      }
      "updateCurrentCustomer" -> {
        updateCurrentCustomer(result)
      }
      "getPaymentMethods" -> {
        getPaymentMethods(when (call.argument<String>("type")) {
          "card" -> PaymentMethod.Type.Card
          "card_present" -> PaymentMethod.Type.CardPresent
          "ideal" -> PaymentMethod.Type.Ideal
          else -> PaymentMethod.Type.Card
        }, result)
      }
      "attachPaymentMethod" -> {
        attachPaymentMethod(call.argument("id")!!, result)
      }
      "detachPaymentMethod" -> {
        detachPaymentMethod(call.argument("id")!!, result)
      }
      "endCustomerSession" -> {
        endCustomerSession()
        result.success(null)
      }
      "createPaymentMethodCard" -> {
        val card = Card.create(call.argument("cardNumber")!!, call.argument("cardExpMonth")!!, call.argument("cardExpYear")!!, call.argument("cardCvv")!!)
        val billingDetails = PaymentMethod.BillingDetails.Builder().setName(call.argument("billingDetailsName")!!).setEmail(call.argument("billingDetailsEmail")!!).build()

        createPaymentMethod(PaymentMethodCreateParams.create(card.toPaymentMethodParamsCard(), billingDetails) , result)
      }
      else -> result.notImplemented()
    }
  }

  private fun init(publishableKey: String) {
    PaymentConfiguration.init(publishableKey)
    stripe = Stripe(activity, PaymentConfiguration.getInstance().publishableKey)
  }

  private fun initCustomerSession() {
    CustomerSession.initCustomerSession(activity) { apiVersion: String, keyUpdateListener: EphemeralKeyUpdateListener ->
      this.keyUpdateListener = keyUpdateListener
      methodChannel.invokeMethod("createEphemeralKey", mapOf("apiVersion" to apiVersion))
    }
  }

  private fun retrieveCurrentCustomer(result: Result) {
    CustomerSession.getInstance().retrieveCurrentCustomer(object : CustomerSession.CustomerRetrievalListener {
      override fun onCustomerRetrieved(customer: Customer) {
        result.success(customer.toMap())
      }

      override fun onError(errorCode: Int, errorMessage: String, stripeError: StripeError?) {
        result.error("0", "Failed to retrieve current customer. Possible connection issues.", null)
      }
    })
  }

  private fun updateCurrentCustomer(result: Result) {
    CustomerSession.getInstance().updateCurrentCustomer(object : CustomerSession.CustomerRetrievalListener {
      override fun onCustomerRetrieved(customer: Customer) {
        result.success(null)
      }

      override fun onError(errorCode: Int, errorMessage: String, stripeError: StripeError?) {
        result.error("0", "Failed to update current customer. Possible connection issues.", null)
      }
    })
  }

  private fun getPaymentMethods(type: PaymentMethod.Type, result: Result) {
    CustomerSession.getInstance().getPaymentMethods(type, object : CustomerSession.PaymentMethodsRetrievalListener {
      override fun onPaymentMethodsRetrieved(paymentMethods: MutableList<PaymentMethod>) {
        result.success(paymentMethods.map { paymentMethod -> paymentMethod.toMap() })
      }

      override fun onError(errorCode: Int, errorMessage: String, stripeError: StripeError?) {
        result.error("0", "Failed to get payment methods. Possible connection issues.", null)
      }
    })
  }

  private fun attachPaymentMethod(id: String, result: Result) {
    CustomerSession.getInstance().attachPaymentMethod(id, object : CustomerSession.PaymentMethodRetrievalListener {
      override fun onPaymentMethodRetrieved(paymentMethod: PaymentMethod) {
        result.success(null)
      }

      override fun onError(errorCode: Int, errorMessage: String, stripeError: StripeError?) {
        result.error("0", "Failed to attach payment method. Possible connection issues.", null)
      }
    })
  }

  private fun detachPaymentMethod(id: String, result: Result) {
    CustomerSession.getInstance().detachPaymentMethod(id, object : CustomerSession.PaymentMethodRetrievalListener {
      override fun onPaymentMethodRetrieved(paymentMethod: PaymentMethod) {
        result.success(null)
      }

      override fun onError(errorCode: Int, errorMessage: String, stripeError: StripeError?) {
        result.error("0", "Failed to detach payment method. Possible connection issues.", null)
      }
    })
  }

  private fun endCustomerSession() {
    CustomerSession.endCustomerSession()
  }

  private fun createPaymentMethod(paymentMethodCreateParams: PaymentMethodCreateParams, result: Result) {
    stripe.createPaymentMethod(paymentMethodCreateParams, object : ApiResultCallback<PaymentMethod> {
      override fun onSuccess(paymentMethod: PaymentMethod) {
        result.success(paymentMethod.toMap())
      }

      override fun onError(e: Exception) {
        result.error("0", "Failed to create payment method", e.localizedMessage)
      }
    })
  }
}
