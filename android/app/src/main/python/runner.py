import sys
from io import StringIO
import traceback

def execute_code(code_string):
    old_stdout = sys.stdout
    redirected_output = sys.stdout = StringIO()
    
    try:
        # تشغيل كود المستخدم
        exec(code_string, globals())
        output = redirected_output.getvalue()
        return output if output else "تم التشغيل بنجاح."
    except Exception:
        return traceback.format_exc()
    finally:
        sys.stdout = old_stdout
