import basic;
struct color{
	int r;
	int g;
	int b;
	import raylib;
	auto get(){
		return Color(cast(ubyte)r,cast(ubyte)g,cast(ubyte)b,255);
	}
	int distence(color a){
		int distence(int a,int b){
			if(a>b){return a-b;}
			return b-a;
		}
		return 
			distence(r,a.r)+
			distence(g,a.g)+
			distence(b,a.b);
	}
	color lerp(color a,float f){
		int safeto(float f){//I need my own conv -__-
			import std.math;
			if(f.isNaN){return 0;}
			return f.to!int;
		}
		return color(
			safeto(r*(1-f)+a.r*f),
			safeto(g*(1-f)+a.g*f),
			safeto(b*(1-f)+a.b*f));
	}
	enum bullshit=color(-1,-1,-1);
	bool isbullshit(){
		return r<0||g<0||b<0;}
	alias get this;
}

string zenity(){ try{
	string exe(string input){//"make the annoying gtk warnings in zenity go away, mmmk?" the function
		import std.process;
		auto config=Config.stderrPassThrough;
		return input.executeShell(null,config).output[0..$-1];
	}
	string s=exe("zenity --file-selection --filename=$PWD/themes/");
	ulong i;
	foreach(j,c;s){if(c=='/'){i=j;}}
	return s[i+1..$];
	}catch(Throwable){
	return "solarized-dark.yaml";
}}

color hextocolor(char[] s){
	import std.range;
	color output;
	//I wish c foreach abuse worked in d
	//for(int i=0,int j=0,bool b=true;i<6;i++,j+=b,b!=b)
	enum zippy= zip(
		[16,1].cycle,
		["r","r","g","g","b","b"],
		iota(0,100));
	static foreach(digit,mix,i;zippy){ {
		int t;
		if(s[i]>='0' && s[i]<='9'){
			t=s[i]-'0';}
		if(s[i]>='a' && s[i]<='f'){
			t=s[i]-'a'+10;}
		if(s[i]>='A' && s[i]<='F'){
			t=s[i]-'A'+10;}
		t*=digit;
		mixin("output."~mix)+=t;
	} }
	return output;
}
//theres isnt exactly a good list of names, all the charts are out of order and missing names
enum colornames=["background","brightbackground","selection","hightlight",
		"darktext","text","brighttext","brightwhite",
		"red","good","yellow","green",
		"cyan","blue","purple","evil"];

mixin template makecolors(
		string defaultfile="solarized-dark.yaml",
		alias fileget=zenity,
		COLOR=color,
		alias colorparse=hextocolor){
	COLOR[16] colors;
	COLOR[16] parsecolors(string file_){ try{
		import std.stdio; import std.string; import std.algorithm;
		auto file=File("themes/"~file_).byLine;
		COLOR[16] temp;
		enum chars=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
		foreach(i,c;chars){
			string s="base0"~c;
			while( ! file.front.canFind(s)){file.popFront;}
			auto hex=file.front.find('"')[1..7];//why is this char[]?
			temp[i]=colorparse(hex);
		}
		
		return temp;
		} catch(Throwable){
			import std.stdio;
			writeln(file_~": FAILED");
			return colors;
	}}
	void loaddefualtcolors(){
		colors=parsecolors(defaultfile);
	}
	void changecolors(){
		colors=parsecolors(fileget);
	}
	static foreach(i,mix;colornames){
		import std.conv;
		mixin("auto ref "~mix~"(){ return colors["~i.to!string~"];}");
	}
}