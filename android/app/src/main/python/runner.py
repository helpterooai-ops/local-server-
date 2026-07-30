import traceback
import threading

# حالة عامة للبوت الحالي
_bot_thread = None
_exec_globals = {}


def _run_bot_in_thread(code_string):
    """تشغيل كود البوت في خيط منفصل مع عزل تام للأخطاء"""
    global _exec_globals
    try:
        exec(code_string, _exec_globals)
    except BaseException:
        # BaseException بدل Exception — يمسك كل شيء حتى SystemExit
        print(f"--- خطأ داخل كود البوت ---\n{traceback.format_exc()}")


def execute_code(code_string):
    global _bot_thread, _exec_globals

    # إيقاف أي بوت سابق شغّال فعليًا قبل ما نبدأ وحد جديد
    if _bot_thread and _bot_thread.is_alive():
        stop_bot()

    _exec_globals = {}
    _bot_thread = threading.Thread(
        target=_run_bot_in_thread, args=(code_string,), daemon=True
    )
    _bot_thread.start()

    return "تم تشغيل البوت بنجاح في الخلفية."


def stop_bot():
    """إيقاف البوت الفعلي (وليس فقط تفريغ مرجع ميت)"""
    global _bot_thread, _exec_globals

    bot = _exec_globals.get('bot')
    if bot is not None and hasattr(bot, 'stop_polling'):
        try:
            bot.stop_polling()
        except Exception:
            pass

    _bot_thread = None
    _exec_globals = {}
    return "تم إيقاف البوت."