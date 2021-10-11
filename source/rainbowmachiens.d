import reusedmachines;
import metric;
import basic;

//unittest{
//	cycle!() foo;
//	foreach(i;1..15){
//		foo.get.writeln;foo++;}}
	


struct statefulout(T,store_){
	T payload;alias payload this;
	store_ store;
	bool isvalid=true;
	bool tryagain=true;
	enum invalid=typeof(this)(T.init,store_.init,false);
	enum invalidandskip=typeof(this)(T.init,store_.init,false,false);
}
//a stateful filer and map together, with lots of "just work for this one example" compermises, ugly to avoid frame shit
struct stateful(M,alias f,int maxskips=50){
	import std.traits;
	alias para=Parameters!f;
	alias input=para[0];
	alias store=para[1];
	//static assert(is(statefulout!(input,store)==typeof(f(input(),store()));
	M mach;
	input out_;
	store store_;
	input get(){return out_;}
	void poke(){
		statefulout!(input,store) temp;
		if(store_==store.init){goto offby1;}
		loop:
		mach++;
		offby1:
		temp=f(mach.get,store_);
		if( ! temp.isvalid){
			if( ! temp.tryagain){mach++;return;}
			goto loop;
		}
		out_=temp;
		store_=temp.store;
	}
	mixin machineopoverloads!();
}
//unittest{
//	alias O=statefulout!(int,int);
//	O ismax(int i,int max){
//		if(i<max){return O.invalid;}
//		return O(i,i);
//	}
//	stateful!(cyclearray!([1,3,2,4]),ismax) foo;
//	foreach(i;1..15){
//		foo.get.writeln;foo++;}}
struct hindsight(M,int past_){
	M mach; alias mach this;
	alias T=typeof(mach.get());
	parroit!T past;//this should be some varuent of parroit that using a ring array
	void poke(){
		mach++;
		past++;
		while(past.store.length<past_){
			past+=mach;}
	}
	T foresight(int i){
		if(i>0){
			static if(true/*detrect if mach defines foresight*/){
				assert(0);
		}}
		if(i==0){return mach;}
		if( (past_+i)>=past.store.length){return bullshitof!T;}
		return past.store[past_+i];
	}
	mixin compositionopoverloads!();
}
//unittest{
//	hindsight!(cycle!10,7) foo;
//	foo++;
//	foreach(i;1..15){
//		foo.get.writeln;
//		foo[-3].writeln;
//		foo[-7].writeln;
//		"---".writeln;
//		foo++;
//	}
//}
