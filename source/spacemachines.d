import reusedmachines;
import metric;
import basic;
struct preplan(M){
	M mach;alias mach this;
	alias T=typeof(mach.get());
	T[] store;
	auto get(){return foresight(0);}
	void poke(){if(store.length>0){
		store=store[1..$];}}
	T foresight(int i){start:
		if(store.length>i){return store[i];}
		mach++;store~=mach;
		goto start;
	}
	mixin compositionopoverloads!();
}
unittest{
	preplan!(cycle!7) foo;
	foo[10].writeln;
	foreach(i;1..15){
		foo.writeln;
		foo.get.writeln;
		"---".writeln;
		foo++;
	}
}