package puremvc.proxy
{
	import flash.net.getClassByAlias;
	
	import mx.utils.UIDUtil;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import puremvc.NotificationNames;
	
	import utils.ObjectUtil;

	public class GReaderCommandProxy extends Proxy
	{
		public static const GREADER_USER:String = "GREADER_USER";
		public static const GREADER_CHECK:String = "GREADER_CHECK";
		public static const GREADER_SUBS:String = "GREADER_SUBS";
		public static const GREADER_UNREAD:String = "GREADER_UNREAD";
		public static const GREADER_GET:String = "GREADER_GET";
		public static const GREADER_MOD_TOKEN:String = "GREADER_MOD_TOKEN";
		public static const GREADER_TAG:String = "GREADER_TAG";
		public static const GREADER_MARK_ALL_READ:String = "GREADER_MARK_ALL_READ";
		public static const GREADER_ADD_SUB:String = "GREADER_ADD_SUB";
		
		public static const GREADER_LOGIN:String = "GREADER_LOGIN";
		public static const GREADER_LOGOUT:String = "GREADER_LOGOUT";
		
		public var action:String;
		
		public function GReaderCommandProxy(action:String, data:Object = null)
		{
			this.action = action;
			super( UIDUtil.createUID(), data);
			
			trace(action, data);
		}
		
		public function result(value:Object):void
		{
			var success:Boolean = true;
			var errorMessage:String = null;
			
			if(value.result.hasOwnProperty("r") && value.result.r.hasOwnProperty("err"))
			{
				success = false;
				errorMessage = value.result.r.err;
				ObjectUtil.deepTrace(value);
			}
			
			
			switch(this.action)
			{
				case GREADER_LOGIN:
					ObjectUtil.deepTrace(value);
					if(success)
						facade.sendNotification( NotificationNames.GREADER_LOGIN_SUCCESS );
					else
						facade.sendNotification( NotificationNames.GREADER_LOGIN_FAIL, errorMessage );
					
					break;
				case GREADER_SUBS:
					//Register Subs
					if(success)
					{
						subscriptionsProxy.setData( value.result );
						facade.sendNotification( NotificationNames.GREADER_SUBSCRIPTIONS_SUCCESS );
					}
					
					break;
				default:
					break;
			}
			trace(value);
		}
		
		public function fault(value:Object):void
		{
			trace("FAIL: ");
			ObjectUtil.deepTrace(value);
		}
		
		/**
		 * Retrieve Proxies
		 **/
		
		private function get subscriptionsProxy():SubscriptionsProxy
		{
			return fetchOrCreateProxyByName(SubscriptionsProxy.NAME) as SubscriptionsProxy;
		}
		
		/**
		 * Helpers
		 **/
		
		private function fetchOrCreateProxyByName(name:String):Proxy
		{
			if (facade.hasProxy( name ))
			{
				return facade.retrieveProxy( name ) as Proxy;
			}
			else
			{
				var ProxyClass:Class = getClassByAlias( name );
				var proxyRef:Proxy = new ProxyClass() as Proxy;
				
				facade.registerProxy( proxyRef );
				return proxyRef;
			}
		}
	}
}