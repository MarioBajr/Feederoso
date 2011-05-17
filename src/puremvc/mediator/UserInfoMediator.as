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
	import puremvc.vo.Label;
	import puremvc.vo.Subscription;
	
	import qnx.ui.data.DataProvider;
	import qnx.ui.data.SectionDataProvider;
	import qnx.ui.events.ListEvent;
	
	import utils.ObjectUtil;
	
	import views.UserInfoView;
	
	public class UserInfoMediator extends Mediator
	{
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
			var labels:Array = DictionaryUtil.getValues(subscriptionsProxy.labelsDict);
			var sectionById:Dictionary = new Dictionary();
			
			var sectionDP:SectionDataProvider = new SectionDataProvider();
			for each(var label:Label in labels)
			{
				var section:Object = new Object();
				section.label = label.title;
				sectionById[label.id] = section;
				sectionDP.addItem( section );
			}
			
			for each(var sub:Subscription in subscriptions)
			{
				for each(label in sub.categories)
				{
					section = sectionById[label.id];
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
				facade.sendNotification( NotificationNames.REQUEST_SUBSCRIPTION_ARTICLES, subscription);
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