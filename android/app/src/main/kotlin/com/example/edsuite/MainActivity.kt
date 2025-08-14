package com.example.edsuite

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.edsuite.niubiz/channel"
    private val REQUEST_NIUBIZ = 1001
    private lateinit var resultCallback: MethodChannel.Result

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            resultCallback = result

            when (call.method) {
                "startNiustart" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=0&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "startTransaction" -> {
                    val monto = call.argument<String>("monto") ?: "0"
                    val useQR = call.argument<Boolean>("useQR") ?: false
                    val uri = if (useQR) {
                        "posweb://transact/?EXTCALLER=appTercera&EXTOP=1&EXTMONTO=$monto&EXTFORQR=1"
                    } else {
                        "posweb://transact/?EXTCALLER=appTercera&EXTOP=1&EXTMONTO=$monto"
                    }
                    launchIntent(uri, result)
                }
                "cancelByReference" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=2&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "cancelByIDU" -> {
                    val idu = call.argument<String>("idu") ?: ""
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=2&EXTIDU=$idu&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "copy_last_transaction" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=13&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "printDuplicate" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=9&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "closeBatch" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=11&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "printTicket" -> {
                    val texto = call.argument<String>("texto") ?: ""
                    if (texto.isBlank()) {
                        result.error("EMPTY_TEXT", "No se recibió texto para imprimir.", null)
                        return@setMethodCallHandler
                    }
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=30&EXTMONTO=0&EXTBODY=$texto"
                    launchIntent(uri, result)
                }
                "multicomercio" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=3&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "reverso" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=4&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "consultaBin" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=5&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun launchIntent(uriString: String, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse(uriString)
            setPackage("com.niubiz.app_financiera")
        }

        val pm: PackageManager = packageManager
        val resolved = intent.resolveActivity(pm)

        if (resolved != null) {
            try {
                startActivityForResult(intent, REQUEST_NIUBIZ)
            } catch (e: Exception) {
                result.error("INTENT_ERROR", "No se pudo lanzar el intent: ${e.message}", null)
            }
        } else {
            Toast.makeText(this, "Niubiz POS no está instalada.", Toast.LENGTH_LONG).show()
            result.error("APP_NOT_FOUND", "Niubiz POS no está instalada en el dispositivo.", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_NIUBIZ) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val extras = data.extras
                val allData = mutableMapOf<String, Any?>()
                extras?.keySet()?.forEach { key ->
                    allData[key] = extras.get(key)
                }
                resultCallback.success(allData)
            } else {
                resultCallback.error("NO_RESULT", "No se recibió resultado desde Niubiz POS", null)
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}
