package com.helpterooai.local_server

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bot_maker/python_channel"
    private var botThread: Thread? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // تهيئة محرك بايثون
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "runPythonBot" -> {
                    val code = call.argument<String>("code")
                    if (code != null) {
                        // تشغيل بايثون في الخلفية (Background Thread) لمنع تعليق التطبيق
                        botThread = thread {
                            try {
                                val py = Python.getInstance()
                                val module = py.getModule("runner")
                                val output = module.callAttr("execute_code", code).toString()
                                
                                // إرجاع النتيجة للواجهة عبر الـ UI Thread
                                Handler(Looper.getMainLooper()).post {
                                    result.success(output)
                                }
                            } catch (e: Exception) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("PYTHON_ERROR", e.message, null)
                                }
                            }
                        }
                        // نرجع للواجهة فوراً أن البوت قيد التشغيل (لا ننتظر انتهاء الحلقة)
                        result.success("تم تشغيل البوت في الخلفية بنجاح.")
                    } else {
                        result.error("INVALID_CODE", "الكود فارغ", null)
                    }
                }
                "stopPythonBot" -> {
                    // إيقاف الـ Thread الذي يعمل عليه البوت
                    botThread?.interrupt()
                    botThread = null
                    result.success("تم إيقاف البوت.")
                }
                else -> result.notImplemented()
            }
        }
    }
}
