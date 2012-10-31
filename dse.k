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
import("curl");
import("konoha.new");
import("konoha.class");
import("konoha.const");
import("konoha.string");
import("konoha.bytes");
import("konoha.file");
import("konoha.date");
import("konoha.eventlistener");
import("cstyle", "while");
import("posix.process");
import("dscript.subproc");

const DTASK_SUCCESS = 0;

class Logger {
	Json data;

	Logger() {
		this.data = new Json();
	}

	void set(String key, String value) {
		this.data.setString(key, value);
	}

	void out() {
		String str = this.data.dump();
		System.p(str); // for debug
		String command = "logger " + str.replace("\"", "\\" + "\"");
		System.system(command);
	}
}

void executeScript(Event e) {
	String cid = e.getProperty("CId");
	String tid;
	String name;
	if(e.getProperty("event") == "D-Control") {
		name = cid;
		tid = "0";
	}
	else if(e.getProperty("event") == "D-Task") {
		name = e.getProperty("Name");
		tid = e.getProperty("TId");
	}
	else {
		System.p("DSE handles only D-Script");
		return;
	}
	String scriptname = name + ".k"
	String script = e.getProperty("Script");
	String to = e.getProperty("To");
	String from = e.getProperty("From");
	String[] strs = to.split(":");
	String localhost = "\\" + "\"" + strs[0] + "\\" + "\"";
	int    port = strs[1].toint();

	FILE f = new FILE(scriptname, "w");
	f.write(script.toBytes());
	f.close();
	System.p("dse received script"); // for debug

	String command = "minikonoha -DHOST=" + localhost + " -DPORT=" + port + " " + scriptname;
	System.p(command); // for debug
	Subproc sp = new Subproc(command, false);
	sp.enableShellmode(false);
	sp.enablePipemodeOUT(true);

	Logger startlog = new Logger();
	startlog.set("Method", "StartTask");
	startlog.set("CId", cid);
	startlog.set("TId", tid);
	startlog.set("State", "start");
	startlog.set("ScriptName", scriptname);
	startlog.set("Ip", to);
	Date starttime = new Date();
	startlog.set("Time", starttime.getTime().toString());
	startlog.out();

	int result = sp.fg();
	String error = sp.communicate("")[0];

	Logger endlog = new Logger();
	endlog.set("Method", "EndTask");
	endlog.set("State", "end");
	endlog.set("CId", cid);
	endlog.set("TId", tid);
	Json sdata = new Json();
	sdata.setString("event", tid);

	if(result == DTASK_SUCCESS) {
		endlog.set("Result", "success");
		sdata.setString("Result", "success");
	}
	else {
		endlog.set("Result", "error");
		endlog.set("ErrorLog", error);
		sdata.setString("result", "error");
	}

	endlog.set("ScriptName", scriptname);
	endlog.set("Ip", to);
	Date endtime = new Date();
	endlog.set("Time", endtime.getTime().toString());
	endlog.out();
	System.p("dse executed script"); // for debug

	String response = sdata.dump();
	System.p("response:" + response); // for debug
	Curl c = new Curl();
	String url = "http://" + from;
	c.setOpt(CURLOPT_URL, url);
	c.setOpt(CURLOPT_POSTFIELDS, response);
	c.perform();
	System.p("dse sended response");

	System.p(error);
}

void DSE() {
	EventHandler.setCallBack("D-Control", executeScript);
	EventHandler.setCallBack("D-Task", executeScript);
	HttpEventListener.start("127.0.0.1", PORT);

	while(true) {
		System.usleep(1000);
	}
}

DSE();
