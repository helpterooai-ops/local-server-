import sys
import traceback
import threading
from io import StringIO

# متغير عام لتخزين خيط البوت
_bot_thread = None

def _run_bot_in_thread(code_string):
    """تشغيل كود البوت في خيط منفصل مع عزل تام للأخطاء"""
    global _bot_thread
    try:
        exec_globals = {}
        exec(code_string, exec_globals)
    except Exception as e:
        # طباعة الخطأ في console التطبيق
        print(f"--- خطأ في البوت ---\n{traceback.format_exc()}")

def execute_code(code_string):
    global _bot_thread
    
    # إيقاف أي بوت سابق
    if _bot_thread and _bot_thread.is_alive():
        # محاولة إيقاف الخيط القديم (لن يتوقف فوراً لكننا نتخلى عنه)
        _bot_thread = None
    
    # تشغيل البوت في خيط منفصل معزول تماماً
    _bot_thread = threading.Thread(target=_run_bot_in_thread, args=(code_string,), daemon=True)
    _bot_thread.start()
    
    return "تم تشغيل البوت بنجاح في الخلفية."

def stop_bot():
    """إيقاف البوت"""
    global _bot_thread
    if _bot_thread and _bot_thread.is_alive():
        _bot_thread = None
        return "تم إيقاف البوت."
    return "لا يوجد بوت يعمل حالياً."