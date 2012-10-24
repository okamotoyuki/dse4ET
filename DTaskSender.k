#!/usr/local/bin/minikonoha

import("konoha.new");
import("konoha.class");
import("konoha.const");
import("konoha.bytes");
import("konoha.file");
import("dscript.task");

const BUFSIZ = 4096;

void sendDTask() {
	FILE script = new FILE(SCRIPT, "r");
	Bytes buf = new Bytes(BUFSIZ);
	buf.setAll(0);
	script.read(buf);
	script.close();
	DTask test = new DTask("test", new String(buf), EVAL);
	test.dispatch("127.0.0.1");
}

sendDTask();
