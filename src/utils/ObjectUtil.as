package utils
{
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;

	public class ObjectUtil
	{
		public static function deepTrace(obj:*, level:int=0 ):void
		{
			var tabs:String = "";
			for ( var i:int = 0 ; i<level; i++)
				tabs += "\t";
			
			for ( var prop:String in obj )
			{
				trace( tabs + "[" + prop + "] -> " + obj[ prop ] );
				deepTrace( obj[ prop ], level + 1 );
			}
		}
		
		public static function getClassName(obj:*):String
		{
			var className:String = getQualifiedClassName( obj );
			registerClassAlias(className, obj);
			trace(className);
			return className;
		}
		
		
	}
}