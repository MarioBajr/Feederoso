package puremvc.proxy
{
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import utils.ObjectUtil;
	
	public class UserInfoProxy extends Proxy
	{
		public var name:String;
		public var id:String;
		
		public function UserInfoProxy()
		{
			super(NAME);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( UserInfoProxy );
		}
		
		override public function setData(data:Object):void
		{
			super.setData( data );
			
			this.name = data.r.name;
			this.id = data.r.u;
		}
	}
}