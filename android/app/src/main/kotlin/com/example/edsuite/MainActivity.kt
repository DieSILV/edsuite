package com.example.edsuite

import android.app.Activity
import android.content.Intent
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
                // 🔹 Inicialización
                "startNiustart" -> {
                    val uri = "niustart://transact/?EXTCALLER=appTercera&EXTOP=0&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 Venta
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

                // 🔹 Anulación
                "cancelByReference" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=2&EXTMONTO=0"
                    launchIntent(uri, result)
                }
                "cancelByIDU" -> {
                    val idu = call.argument<String>("idu") ?: ""
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=2&EXTIDU=$idu&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 Reverso
                "reverso" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=4&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 Consulta BIN
                "consultaBin" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=5"
                    launchIntent(uri, result)
                }

                // 🔹 Duplicado
                "printDuplicate" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=9&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 Cierre de lote
                "closeBatch" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=11&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 Histórico de cierre de lote
                "batchHistory" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=12"
                    launchIntent(uri, result)
                }

                // 🔹 Copia de Voucher
                "copy_last_transaction" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=13&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 Detalle de reportes
                "reportsDetail" -> {
                    val uri = "posweb://transact/?EXTCALLER=appTercera&EXTOP=14"
                    launchIntent(uri, result)
                }

                // 🔹 Multicomercio
                "multicomercio" -> {
                    val uri = "niustart://transact/?EXTCALLER=appTercera&EXTOP=3&EXTMONTO=0"
                    launchIntent(uri, result)
                }

                // 🔹 POS Servicios
                "posServicios" -> {
                    val business = call.argument<String>("business") ?: ""
                    val function = call.argument<String>("function") ?: ""
                    val uri = "posservices://transact/?EXTCALLER=appTercera&EXTOP=20&EXTBUSINESS=$business&EXTFUNCTION=$function"
                    launchIntent(uri, result)
                }

                // 🔹 Scanner
                "scanner" -> {
                    val uri = "niustart://transact/?EXTCALLER=appTercera&EXTOP=40"
                    launchIntent(uri, result)
                }

                // 🔹 Impresión texto
                "printTicket" -> {
                    val texto = call.argument<String>("texto") ?: ""
                    if (texto.isBlank()) {
                        result.error("EMPTY_TEXT", "No se recibió texto para imprimir.", null)
                        return@setMethodCallHandler
                    }
                    val uri = "niustart://transact/?EXTCALLER=appTercera&EXTOP=30&EXTMONTO=0&EXTBODY=$texto"
                    launchIntent(uri, result)
                }

                // 🔹 Impresión imagen
                "printImage" -> {
                    val base64 = call.argument<String>("base64") ?: ""
                    val uri = "niustart://transact/?EXTCALLER=appTercera&EXTOP=31&EXTPRINTIMAGE=$base64"
                    launchIntent(uri, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    // 🔹 Método para lanzar Intents con paquetes correctos
    private fun launchIntent(uriString: String, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse(uriString)

            // Mapear paquete correcto
            when {
                uriString.startsWith("niustart://") -> {
                    // Inicialización, multicomercio, impresión
                    setPackage("pe.com.niubiz.app.start")
                }
                uriString.startsWith("posweb://") -> {
                    // Ventas, anulaciones, reversos, reportes
                    setPackage("pe.com.niubiz.app.payment")
                }
                uriString.startsWith("posservices://") -> {
                    // POS Servicios
                    setPackage("pe.com.niubiz.app.payment")
                }
                else -> {
                    // Fallback a payment
                    setPackage("pe.com.niubiz.app.payment")
                }
            }
        }

        try {
            startActivityForResult(intent, REQUEST_NIUBIZ)
        } catch (e: Exception) {
            Toast.makeText(this, "No se pudo lanzar el intent: ${e.message}", Toast.LENGTH_LONG).show()
            result.error("INTENT_ERROR", "No se pudo lanzar el intent: ${e.message}", null)
        }
    }

    // 🔹 Manejo de resultados
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_NIUBIZ) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val props = data.extras
                val response = mutableMapOf<String, Any?>()

                props?.keySet()?.forEach { key ->
                    response[key] = props.get(key)
                }

                // Parámetros clave del SDK
                response["PWRIPARAMS"] = props?.getString("PWRIPARAMS")
                response["CODE"] = props?.getString("CODE")

                resultCallback.success(response)
            } else {
                resultCallback.error("NO_RESULT", "No se recibió resultado desde Niubiz POS", null)
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}