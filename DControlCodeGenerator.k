import("jansson");
import("konoha.new");
import("konoha.class");
import("konoha.array");
import("konoha.string");
import("konoha.bytes");
import("konoha.file");
import("posix.process");
import("cstyle", "while");

String generateFunctionFromTaskGroup(String DControlScript, Json taskGroup, String funcName, int n) {
	String[] keys = taskGroup.getKeys();
	System.p(keys);
	int num = keys.getSize();
	int i;

	if(n == 0) {
		DControlScript = DControlScript + "void Func0() {\n";

		i = 0;
		while(i < num) {
			Json task = taskGroup.getJson(keys[i]);
			System.p(task);
			String name = task.getString("Name");
			String script = task.getString("Script");
			String ip = task.getString("Ip");
			DControlScript = DControlScript + "\tDTask " + name + " = new DTask(\"" + name + "\", \"" + script + "\", EVAL);\n";
			DControlScript = DControlScript + "\t" + name + ".end = " + funcName + ";\n";
			DControlScript = DControlScript + "\t" + name + ".dispatch(\"" + ip.split(":")[0] + "\", " + ip.split(":")[1] + ");\n";
			i = i + 1;
		}

		DControlScript = DControlScript + "}\n\n";
	}
	else {
		String globalVariableName = "GlobalVariable" + n;
		DControlScript = DControlScript + "int " + globalVariableName + "= 0;\n\n";

		DControlScript = DControlScript + "void Func" + n + "(Event e) {\n";
		DControlScript = DControlScript + "\tglobal." + globalVariableName +  " = " + "global." + globalVariableName + " + 1;\n\n";

		DControlScript = DControlScript + "\tif(global." + globalVariableName +  " == " + num + ") {\n";

		i = 0;
		while(i < num) {
			Json task = taskGroup.getJson(keys[i]);
			System.p(task);
			String name = task.getString("Name");
			String script = task.getString("Script");
			String ip = task.getString("Ip");
			DControlScript = DControlScript + "\t\tDTask " + name + " = new DTask(\"" + name + "\", \"" + script + "\", EVAL);\n";
			DControlScript = DControlScript + "\t\t" + name + ".end = " + funcName + ";\n";
			DControlScript = DControlScript + "\t\t" + name + ".dispatch(\"" + ip.split(":")[0] + "\", " + ip.split(":")[1] + ");\n";
			i = i + 1;
		}

		DControlScript = DControlScript + "\t}\n\n";
		DControlScript = DControlScript + "}\n\n";
	}

	return DControlScript;
}

void main() {
/* sample */
	Json[] tgl = new Json[0];
	Json tA = new Json();
	tA.setString("Name", "taskA");
	tA.setString("Script", "System.p(1)");
	tA.setString("Ip", "127.0.0.1:8080");
	Json tg1 = new Json();
	tg1.setJson("1", tA);
	Json tB = new Json();
	tB.setString("Name", "taskB");
	tB.setString("Script", "System.p(2)");
	tB.setString("Ip", "127.0.0.1:8080");
	Json tg2 = new Json();
	tg2.setJson("1", tB);
	tgl.add(tg1);
	tgl.add(tg2);
	Json d = new Json();
	d.setString("Cid", "cid");
	d.setArray("TaskGroupList", tgl);

/* headder */
	String DControlScript = "";
	DControlScript = DControlScript + "import(\"konoha.new\");\n";
	DControlScript = DControlScript + "import(\"konoha.class\");\n";
	DControlScript = DControlScript + "import(\"konoha.global\");\n";
	DControlScript = DControlScript + "import(\"konoha.const\");\n";
	DControlScript = DControlScript + "import(\"konoha.bytes\");\n";
	DControlScript = DControlScript + "import(\"konoha.file\");\n";
	DControlScript = DControlScript + "import(\"posix.process\");\n";
	DControlScript = DControlScript + "import(\"cstyle\", \"while\");\n";
	DControlScript = DControlScript + "import(\"dscript.control\");\n\n";
	DControlScript = DControlScript + "const BUFSIZ = 4096\n\n";
	DControlScript = DControlScript + "int GlobalVariableLast = 0;\n\n";

	Json input = d;

	Json[] taskGroupList = input.getArray("TaskGroupList");
	int listLength = taskGroupList.getSize();
	int i = listLength - 1;
	String funcName = "FuncLast";

	DControlScript = DControlScript + "void FuncLast(Event e) {\n";
	DControlScript = DControlScript + "\tglobal.GlobalVariableLast = global.GlobalVariableLast + 1;\n\n";
	DControlScript = DControlScript + "\tif(global.GlobalVariableLast == " + taskGroupList[i].getKeys().getSize() + ")\n";
	DControlScript = DControlScript + "\t\tSystem.system(\"kill \" + System.getpid());\n";
	DControlScript = DControlScript + "\t}\n";
	DControlScript = DControlScript + "}\n\n";

	while(0 <= i) {
		Json taskGroup = taskGroupList[i];
		System.p(taskGroup);
		DControlScript = generateFunctionFromTaskGroup(DControlScript, taskGroup, funcName, i);
		funcName = "Func" + i;
		i = i - 1;
	}

	DControlScript = DControlScript + "void controller() {\n";
	DControlScript = DControlScript + "\tSystem.p(\"D-Control started\");\n";
	DControlScript = DControlScript + "\tDControl.start(\"127.0.0.1\", 8099, \"" + input.getString("Cid") + "\");\n";
	DControlScript = DControlScript + "\tFunc0();\n\n";
	DControlScript = DControlScript + "\twhile(true) {\n";
	DControlScript = DControlScript + "\t\tSystem.usleep(1);\n";
	DControlScript = DControlScript + "\t}\n";
	DControlScript = DControlScript + "}\n\n";
	DControlScript = DControlScript + "controller();";

/* generate file */
	FILE fp = new FILE("test.k", "w");
	fp.write(DControlScript.toBytes());
	fp.close();
}

main();
