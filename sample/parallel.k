import("konoha.new");
import("konoha.class");
import("konoha.global");
import("konoha.const");
import("konoha.bytes");
import("konoha.file");
import("posix.process");
import("cstyle", "while");
import("dscript.control");

const BUFSIZ = 4096;

int finishedTaskAs = 0;

void processAfterTaskA(Event e) {
	global.finishedTaskAs = global.finishedTaskAs + 1;
	if(global.finishedTaskAs == 2) {
		System.p("taskAs done");
		FILE f = new FILE("hoge", "w");
		return;
	}
}

void controller() {
	FILE script = new FILE("sample/sleep.k", "r");
	Bytes buf = new Bytes(BUFSIZ);
	buf.setAll(0);
	script.read(buf);
	script.close();

	System.p("DControl started");
	DControl.start("127.0.0.1", 8077, "cid");
	DTask taskA = new DTask("taskA", new String(buf), EVAL);
	taskA.end = processAfterTaskA;
	taskA.dispatch("127.0.0.1", 8079);
	taskA.dispatch("127.0.0.1", 8078);
	while(true) {
		System.usleep(1);
	}
}

controller();
