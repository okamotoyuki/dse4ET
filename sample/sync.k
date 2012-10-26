import("konoha.new");
import("konoha.class");
import("konoha.global");
import("konoha.const");
import("konoha.bytes");
import("konoha.file");
import("posix.process");
import("cstyle", "while");
import("dscript.task");

const BUFSIZ = 4096;

void processAfterTaskA(Event e) {
	System.p("taskA done");
	FILE f = new FILE("hoge", "w");
}

void controller() {
	FILE script = new FILE("sample/sleep.k", "r");
	Bytes buf = new Bytes(BUFSIZ);
	buf.setAll(0);
	script.read(buf);
	script.close();

	System.p("DControl started");
	DControl.start("127.0.0.1", 8078, "cid");
	DTask taskA = new DTask("taskA", new String(buf), EVAL);
	taskA.end = processAfterTaskA;
	taskA.dispatch("127.0.0.1", 8079);
	while(true) {
		System.usleep(1);
	}
}

controller();
