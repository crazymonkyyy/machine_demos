import basic;

int bar(int a){return a;}
float bar(float a){return a;}
struct foo(T,S=typeof(bar(T()))){
	T playload;
	S store;
}
unittest{
	foo!int foobar;
	foobar.store=1;
}
unittest{
	foo!float foobar;
	foobar.store=3.14;
	foobar.store.writeln;
}
//template foo(T,alias init=sanedefault!T)

template faz(alias t){
	alias T=typeof(t);
	struct faz_(T,T t){
		T payload=t;
	}
	alias faz=faz_!(T,t);
}
unittest{
	faz!"hello" baz;
	baz.writeln;
}