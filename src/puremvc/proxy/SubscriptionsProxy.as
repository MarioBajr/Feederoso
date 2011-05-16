package puremvc.proxy
{
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import puremvc.vo.Subscription;
	
	import utils.ObjectUtil;
	
	public class SubscriptionsProxy extends Proxy
	{
		public var subscriptionsList:Array;
		
		public function SubscriptionsProxy()
		{
			super(SubscriptionsProxy.NAME);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( SubscriptionsProxy );
		}
		
		override public function setData(data:Object):void
		{
			super.setData( data );
			
			this.subscriptionsList = new Array();
			
			var xml:XML = data as XML;
			for each(var item:XML in xml.list.object)
			{
				var sub:Subscription = new Subscription();
				sub.setUpModelWithXML( item );
				
				this.subscriptionsList.push( sub );
			}
			//trace(data);
		}
	}
}