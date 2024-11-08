package red.core 
{
	import flash.display.DisplayObject;
	
	public interface IGameAdapter
	{
		function registerDataBinding( key:String, closure:Object, boundObject:Object = null, isGlobal:Boolean = false ):void;
		function unregisterDataBinding( key:String, closure:Object, boundObject:Object = null ):void;
		function registerChild( spriteParent:DisplayObject, childName:String ):void;
		function unregisterChild():void;
		function callGameEvent( eventName:String, eventArgs:Array ):void;
		
		function registerRenderTarget( targetName:String, width:uint, height:uint ):void;
		function unregisterRenderTarget( targetName:String ):void;
	}
}