# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import threading
from gi.repository import Gdk, GLib, GObject

global_threading_lock = threading.Lock()


def set_cursor(object_, cursor=None):
	"""Set cursor for given gui structure if possible"""
	for widget in object_.gui.values():
		try:
			widget.get_window().set_cursor(cursor)
			break
		except Exception:
			pass


def multithread(handler):
	"""Multithread decorator"""
	def action(*args, **kwargs):
		with global_threading_lock:
			try:
				finalize_signal = handler(*args, **kwargs)
				GLib.idle_add(on_done, finalize_signal, args[0])
			except Exception as e:
				print("Error in multithreading:\n%s" % str(e))

	def on_done(signal, inst):
		set_cursor(inst)
		if isinstance(signal, str) and signal.replace("_", "-") in GObject.signal_list_names(inst):
			inst.emit(signal)

	def wrapper(*args, **kwargs):
		set_cursor(args[0], Gdk.Cursor(Gdk.CursorType.WATCH))

		thread = threading.Thread(target=action, args=args, kwargs=kwargs)
		thread.daemon = True
		thread.start()

	return wrapper
