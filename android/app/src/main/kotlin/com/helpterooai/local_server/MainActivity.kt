package com.helpterooai.local_server

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bot_maker/python_channel"
    private val TAG = "PythonBotChannel"
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

                                Handler(Looper.getMainLooper()).post {
                                    result.success(output)
                                }
                            } catch (e: Throwable) {
                                // Throwable بدل Exception — عشان نمسك حتى أخطاء
                                // نوع Error (مثل UnsatisfiedLinkError) اللي كانت
                                // تفلت من الكود القديم وتقفل التطبيق بصمت كامل
                                val fullError =
                                    "${e.javaClass.name}: ${e.message}\n${Log.getStackTraceString(e)}"
                                Log.e(TAG, "Python bot crashed:\n$fullError")
                                Handler(Looper.getMainLooper()).post {
                                    result.error("PYTHON_ERROR", fullError, null)
                                }
                            }
                        }
                        // لا نرسل result.success هنا! ننتظر انتهاء thread
                    } else {
                        result.error("INVALID_CODE", "الكود فارغ", null)
                    }
                }
                "stopPythonBot" -> {
                    botThread = null
                    try {
                        val py = Python.getInstance()
                        val module = py.getModule("runner")
                        val output = module.callAttr("stop_bot").toString()
                        result.success(output)
                    } catch (e: Throwable) {
                        Log.e(TAG, "stopPythonBot failed: ${e.message}")
                        result.success("تم إيقاف البوت.")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}