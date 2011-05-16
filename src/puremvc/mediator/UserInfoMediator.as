package puremvc.mediator
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.GReaderProxy;
	import puremvc.proxy.SubscriptionsProxy;
	import puremvc.service.GReaderClient;
	
	import qnx.ui.data.DataProvider;
	
	import utils.ObjectUtil;
	
	import views.UserInfoView;
	
	public class UserInfoMediator extends Mediator
	{
		public function UserInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( UserInfoMediator );
		}
		
		/**
		 * Override Methods
		 **/
		
		override public function onRegister():void
		{
			trace("Register Aqiu tb");
		}
		
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
			this.view.subscriptionsList.dataProvider = new DataProvider(subscriptionsProxy.subscriptionsList);
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