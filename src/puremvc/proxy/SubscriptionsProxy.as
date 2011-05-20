package puremvc.proxy
{
	import com.adobe.utils.DictionaryUtil;
	
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import puremvc.vo.Subscription;
	import puremvc.vo.Tag;
	
	import utils.ObjectUtil;
	
	public class SubscriptionsProxy extends Proxy
	{
		
		public var subscriptionsList:Array;
		public var tagDict:Dictionary;
		public var subscriptionById:Dictionary;
		private var waitingSubsToProcess:Boolean;
		
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
			this.tagDict = new Dictionary();
			this.subscriptionById = new Dictionary();
			
			var xml:XML = data as XML;
			for each(var item:XML in xml.list.object)
			{
				var sub:Subscription = new Subscription();
				sub.setUpModelWithXML( item );
				subscriptionById[sub.id] = sub;
				
				for each(var label:Tag in sub.categories)
				{
					this.tagDict[label.id] = label;
				}
				
				this.subscriptionsList.push( sub );
			}
		}
		
		public function processUnreadCount(data:Object):void
		{	
			for each(var unreadFeed:Object in data.r.feed)
			{
				var sub:Subscription = subscriptionById[unreadFeed.id];
				if(sub)
					sub.unreadCount = unreadFeed.count;
			}
		}
	}
}