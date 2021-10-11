import basic;
import raylib;
struct vec2{
	Vector2 payload; alias payload this;
	this(int x,int y){
		payload = Vector2(x.to!float,y.to!float);}
	bool isbullshit(){
		import std.math;
		return payload.x.isNaN;}
}