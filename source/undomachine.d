struct nullable(T){
	T payload;
	bool isnull=true;
	void opAssign(T foo){
		payload=foo; isnull=false;}
	this(T a){
		payload=a;
		isnull=false;
	}
	alias payload this;
	//enum bullshit=this.init;
}
struct undo(M,R,alias input,int maxundos){
	M game;
	M gameold;
	alias I=typeof(input().payload);
	import reusedmachines;
	parroit!I storedinput;
	int timedelay=0;
	R renderer;
	ref M get(){return game;}
	void poke(){
		auto i=input();
		if( ! i.isnull){
			if(timedelay==maxundos){
				gameold+=storedinput;storedinput++;
				storedinput+=i;
				game+=i;
				gameold++;
				game++;
			} else {
				timedelay++;
				storedinput+=i;
				game+=i;
				game++;
		}}
		renderer+=game;
	}
	M foresight(int i){
		assert(i<0);
		//assert(timedelay+i>=0,"not implimented");//may be to egger?
		if(timedelay+i>=0){i=-timedelay;}
		int setup=timedelay+i;
		M gamenew=gameold;
		parroit!I inputs=storedinput;
		foreach(j;0..timedelay+1){
			gamenew+=inputs;
			gamenew++;inputs++;
		}
		return gamenew;
	}
	void pull(){
		game=foresight(-1);
		if(storedinput.store.length>0){
			storedinput.store=storedinput.store[0..$-1];}
		timedelay--;
	}
	import reusedmachines;
	mixin machineopoverloads!();
}