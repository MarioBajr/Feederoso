package puremvc.mediator
{
	import com.adobe.protocols.dict.Dict;
	import com.adobe.utils.DictionaryUtil;
	
	import flash.utils.Dictionary;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.GReaderProxy;
	import puremvc.proxy.SubscriptionsProxy;
	import puremvc.service.GReaderClient;
	import puremvc.vo.Subscription;
	import puremvc.vo.Tag;
	
	import qnx.ui.data.DataProvider;
	import qnx.ui.data.SectionDataProvider;
	import qnx.ui.events.ListEvent;
	
	import utils.ObjectUtil;
	
	import views.UserInfoView;
	
	public class UserInfoMediator extends Mediator
	{
		private var lastIdentifier:String;
		
		public function UserInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			this.view.subscriptionsSectionList.addEventListener(ListEvent.ITEM_CLICKED, onItemClicked);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( UserInfoMediator );
		}
		
		/**
		 * Override Methods
		 **/
		
		override public function listNotificationInterests():Array
		{
			return [
				NotificationNames.GREADER_LOGIN_SUCCESS,
				NotificationNames.GREADER_SUBSCRIPTIONS_SUCCESS
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var notificationName:String = notification.getName();
			var notificationBody:Object = notification.getBody();
			
			switch(notificationName)
			{
				case NotificationNames.GREADER_LOGIN_SUCCESS:
					readerClient.getSubscriptions();
					break;
				case NotificationNames.GREADER_SUBSCRIPTIONS_SUCCESS:
					this.reloadSubscriptions();
					break;
			}
		}
		
		/**
		 * View Logic
		 **/
		
		private function reloadSubscriptions():void
		{
			var subscriptions:Array = subscriptionsProxy.subscriptionsList;
			var tags:Array = DictionaryUtil.getValues(subscriptionsProxy.tagDict);
			var sectionById:Dictionary = new Dictionary();
			
			tags.sortOn(["title"], [Array.DESCENDING]);
			
			var sectionDP:SectionDataProvider = new SectionDataProvider();
			for each(var tag:Tag in tags)
			{
				var section:Object = new Object();
				section.label = tag.title;
				sectionById[tag.id] = section;
				sectionDP.addItem( section );
			}
			
			for each(var sub:Subscription in subscriptions)
			{
				for each(tag in sub.categories)
				{
					section = sectionById[tag.id];
					sectionDP.addChildToItem(sub, section);
				}
			}
			
			this.view.subscriptionsSectionList.dataProvider = sectionDP;
		}
		
		private function onItemClicked(event:ListEvent):void
		{
			if(event.data is Subscription)
			{
				var subscription:Subscription = event.data as Subscription;
				
				if (lastIdentifier != subscription.id)
					facade.sendNotification( NotificationNames.REQUEST_SUBSCRIPTION_ARTICLES, subscription);
				
				this.lastIdentifier = subscription.id;
			}
		}
		
		/**
		 * Getters and Setters
		 **/
		
		public function get view():UserInfoView
		{
			return this.getViewComponent() as UserInfoView;
		}
		
		private function get readerClient():GReaderClient
		{
			return facade.retrieveProxy( GReaderProxy.NAME ).getData() as GReaderClient;
		}
		
		private function get subscriptionsProxy():SubscriptionsProxy
		{
			return facade.retrieveProxy( SubscriptionsProxy.NAME ) as SubscriptionsProxy;
		}
	}
}