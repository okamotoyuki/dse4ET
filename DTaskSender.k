#!/usr/local/bin/minikonoha

import("konoha.new");
import("konoha.class");
import("konoha.const");
import("konoha.string");
import("konoha.bytes");
import("konoha.file");
import("dscript.control");

const BUFSIZ = 4096;

void sendDTask() {
	DControl.start("127.0.0.1", 80, "cid");
	FILE script = new FILE(SCRIPT, "r");
	Bytes buf = new Bytes(BUFSIZ);
	buf.setAll(0);
	script.read(buf);
	script.close();
	DTask task = new DTask(SCRIPT, new String(buf), EVAL);
	task.dispatch("127.0.0.1");
}

sendDTask();
