int lerp(int a,int b,float f){
	if(f==0){return a;}
	if(f==1){return b;}
	return cast(int)(a*(1-f)+b*f);
}
template bullshitof(T:int){
	enum bullshitof=int.min;}
template bullshitof(T){
	enum bullshitof=T.bullshit;}
bool isbullshit(int i){return i==int.min;}
int distence(int a,int b){
	if(a>b){return a-b;}
	return b-a;
}
import raylib;
template bullshitof(T:Vector2){
	enum bullshitof=Vector2.init;}
bool isbullshit(T)(T a){
	return a==bullshitof!T;}
int distence(Vector2 a,Vector2 b){
	import std.conv;import std.math;
	if((a-b).length.isNaN){return int.max;}
	return (a-b).length.to!int;}
Vector2 lerp(Vector2 a,Vector2 b,float f){
	if(a==Vector2.init){return b;}
	if(b==Vector2.init){return a;}
	return a*(1-f)+b*f;
}