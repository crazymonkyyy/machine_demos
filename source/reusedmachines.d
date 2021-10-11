import metric;
mixin template machineopoverloads(){
	void opUnary(string s:"++")(){
		this.poke;}
	import std.traits;
	//static if(hasMember!(this,"get")){
	//static if(__traits(hasMember,this,"get")){
	static if(__traits(compiles,mixin("get()"))){//I dont get it, is traits buggy?
		alias get this;
	}else{
		auto get()(){return this;}
	}
	void opOpAssign(string s:"+",T)(T a){
		give(a);
	}
	auto opIndex(T:int)(T i){//hack to make it wait to be initualized
		return foresight(i);
	}
}
mixin template compositionopoverloads(){
	void opUnary(string s:"++")(){
		this.poke;}
	void opOpAssign(string s:"+",T)(T a){
		give(a);
	}
	auto opIndex(T:int)(T i){return foresight(i);}
}
struct smooth(M){
	M mach; alias mach this;
	auto opSlice(int i,int j){
		return mach[i].lerp(mach[j],.5);
	}
	mixin compositionopoverloads!();
}
struct counter(int to=10){
	int i;
	int max=to;
	auto get(){return i;}
	void poke(){i++;assert(! (i>max));}
	bool ishalt(){return i==max;}
	mixin machineopoverloads!();
}
struct selfrebooting(M,bool detectloops=false){
	M mach; alias mach this;
	static if(detectloops){
		M storedfailedstate;
	}
	void checkhalt(){
		if(mach.ishalt){
			static if(detectloops){
				if(mach==storedfailedstate){goto exit;}
				storedfailedstate=mach;
			}
			mach=M.init;
		}
		exit:
	}
	/* ref? */ auto get(){
		checkhalt();
		return mach.get;
	}
	void poke(){if( ! ishalt){mach++;}}
	bool ishalt(){
		checkhalt();
		static if(detectloops){
			return mach.ishalt&&storedfailedstate;
		} else {
			return false;
		}
	}
	static if(detectloops){
		bool isstable(){
			return /*mach.isstable ||*/ storedfailedstate==mach;//need interspection tools to look for is stable defination
		}
	}
	mixin compositionopoverloads!();
}
template cycle(int to=10){
	alias cycle=selfrebooting!(counter!to);}
struct vomiter(alias f){
	alias T=typeof(f());
	T store=bullshitof!T;
	T get(){return store;}
	void poke(){store=f();}
	mixin machineopoverloads!();
}
//unittest{
//	int foo(){return 3;}
//	vomiter!foo bar;
//}
struct delayassign(T){
	T current=bullshitof!T;
	T future=bullshitof!T;
	T get(){ return current;}
	void poke(){current=future;}
	T foresight(int i){
		if(i!=0){return future;}
		else{return current;}
	}
	bool isstable(){return current==future;}
	bool iserror(){return current.isbullshit;}
	void give(T a){
		if(current.isbullshit){current=a;}
		future=a;
	}
	mixin machineopoverloads!();
}
struct slowlerp(T,int slow_=10){
	delayassign!T state;
	counter!slow_ count;
	ref int slow(){return count.max;}//cause its speed^-1 mmmmmk
	T get(){
		return state.lerp(state[1], cast(float)count/slow);}
	void poke(){
		if( ! state.isstable){count++;}
		if(count.ishalt){
			state++;
			count.i=0;
		}
	}
	void give(T a){
		if(state.future==a){return;}
		state+=get;
		count.i=0;
		state++;
		state+=a;
	}
	T foresight(int i){
		int j=count+i;
		if(j>slow){return state[1];}
		return state.lerp(state[1], cast(float)j/slow);
	}
	bool isstable(){return count.ishalt||state.isstable;}
	mixin machineopoverloads!();
}
//unittest{
//	slowlerp!int foo;
//	foo+=1;
//	foo+=10;
//	foreach(i;0..15){
//		foo.get.writeln;foo++;}
//}
template aristotlegoto(T,alias speed){
	alias D=typeof(T().distence(T()));
	struct aristotlegoto_(T,D speed_){
		slowlerp!T mach; alias mach this;
		D speed=speed_;
		void give(T a){
			mach.slow=1;//???? without this it wasnt initualizing a new state correcly for whatever reason
			mach+=a;
			mach.slow=mach.state[0].distence(mach.state[1])/speed;
		}
		bool isstable(){return mach.isstable || mach.get.isbullshit;}
		mixin compositionopoverloads!();//is this correct? Its not really a composite but im just motifing a single function
	}
	alias aristotlegoto=aristotlegoto_!(T,speed);
}
//unittest{
//	aristotlegoto!(int, 3) foo;
//	foo+=1;
//	foo+=9;
//	foreach(i;1..5){
//		foo.get.writeln;foo++;
//	}
//	foo+=-7;
//	foreach(i;1..10){
//		foo.get.writeln;foo++;
//	}
//}
template path(M,alias speed){//makes 2 bullshit states for some reason todo
	alias T=typeof(M().get());
	//alias D=typeof(distence(T(),T()));
	struct path_{
		M points;
		aristotlegoto!(T,speed) where;
		auto get(){return where.get;}
		void poke(){
			if(where.isstable){
				where+=points.get;
				points++; where++;
			}else{
				where++;
		}}
		auto give(T)(T a){points+=a;}
		mixin machineopoverloads!();
	}
	alias path=path_;
}
//unittest{
//	path!(cyclearray!([1,-7,3,-5]),3) foo;
//	foreach(i;1..50){
//		//foo.writeln;
//		//foo.points.get.writeln;
//		//foo.where.writeln;
//		//
//		//foo.where.isstable.writeln;
//		foo.get.writeln;
//		foo++;
//	}
//}
struct map(M,alias f){
	M mach; alias mach this;
	auto get(){
		return f(mach.get);}
	mixin compositionopoverloads!();//I want this to be a normal machine as I make taffic lights, im unsure why it isnt but it makes errors when I swap it, maybe I need to think about these discintions more?
}
//unittest{
//	auto bar(int i){return i*2;}
//	map!(cycle!(),bar) foo;
//	foreach(i;1..15){
//		foo.get.writeln;foo++;}}

template cyclearray(alias data_){
	alias T=typeof(data_[0]);
	enum T[] data =data_;
	T lookup(int i){return data[i%$];}
	alias cyclearray=map!(cycle!(data.length),lookup);
}
//unittest{
//	cyclearray!([1,2,420,1337]) foo;
//	foreach(i;1..15){
//		foo.get.writeln;foo++;}}

template cycleoutsidearray(alias data){
	alias T=typeof(data[0]);
	T lookup(int i){return data[i%$];}
	struct cycleoutsidearray_{
		map!(cycle!(),lookup) mach;
		void poke(){
			import std.conv;//oh my god int promotion rules
			mach.max=data.length.to!int;
			mach++;
		}
		auto get(){return mach.get;}
		mixin machineopoverloads!();
	}
	alias cycleoutsidearray=cycleoutsidearray_;
}
//unittest{
//	int[] foo=[1,2,3];
//	cycleoutsidearray!foo bar;
//	foreach(i;1..15){
//		bar.get.writeln;bar++;}
//	foo~=4;
//	foreach(i;1..15){
//		bar.get.writeln;bar++;}
//	foo=[2,4,6,8];
//	foreach(i;1..15){
//		bar.get.writeln;bar++;}
//	foo.length=2;
//	foreach(i;1..15){
//		bar.get.writeln;bar++;}
//}
struct parroit(T){
	T[] store;
	T get(){
		if(store.length==0){return bullshitof!T;}
		return store[0];
	}
	void poke(){
		if(store.length>0){
			store=store[1..$];}}
	bool iserror(){return store.length==0;}
	void give(T a){store~=a;}
	mixin machineopoverloads!();
}
//unittest{
//	parroit!int foo;
//	foo+=1;
//	foo+=2;
//	foo+=3;
//	foreach(i;1..5){
//		foo.get.writeln;foo++;
//	}
//}
