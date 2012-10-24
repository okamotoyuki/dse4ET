#!/usr/local/bin/minikonoha

/****************************************************************************
 * Copyright (c) 2012, the Konoha project authors. All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ***************************************************************************/

import("jansson");
import("konoha.new");
import("konoha.class");
import("konoha.bytes");
import("konoha.file");
import("cstyle", "while");
import("posix.process");
import("dscript.eventlistener");
import("dscript.subproc");

class Logger {
	Json data;

	Logger(void) {
		this.data = new Json();
	}

	void set(String key, String value) {
		this.data.setString(key, value);
	}

	void out() {
		Subproc sp = new Subproc("", false);
		sp.enableShellmode(false);
		String command = "logger " + this.data.dump();
		sp.exec(command);
	}
}

void executeScript(Event e) {
	String name = e.getProperty("name");
	String script = e.getProperty("script");
	FILE f = System.fopen("./" + name + ".k", "w");
	f.write(script.toBytes());
	f.close();
	Subproc sp = new Subproc("", false);
	sp.enableShellmode(false);
	String command = "minikonoha " + name + ".k";
	Logger startlog = new Logger();
	startlog.set("state", "start");
	startlog.out();
	String result = sp.exec(command);
	Logger endlog = new Logger();
	endlog.set("state", "end");
	endlog.out();
	System.p(result);
}

void DSE() {
	EventHandler.setCallBack("D-Task", executeScript);

	HttpEventListener.start("127.0.0.1", 8080);

	while(true) {
		System.usleep(1000);
	}
}

DSE();
