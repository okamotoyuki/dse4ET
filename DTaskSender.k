import("konoha.new");
import("konoha.class");
import("dscript.task");

void test() {
	DTask taskA = new DTask("taskA", "System.p(\"hoge\");", EVAL);
	taskA.dispatch("127.0.0.1");
}

test();
