package puremvc.mediator
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.ArticlesProxy;
	import puremvc.proxy.GReaderProxy;
	import puremvc.service.GReaderClient;
	import puremvc.vo.Subscription;
	
	import qnx.ui.data.DataProvider;
	
	import utils.ObjectUtil;
	
	import views.ArticlesView;
	
	public class ArticlesMediator extends Mediator
	{
		private var subscription:Subscription;
		
		public function ArticlesMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( ArticlesMediator );
		}
		
		/**
		 * Override Methods
		 **/
		
		override public function listNotificationInterests():Array
		{
			return [
				NotificationNames.REQUEST_SUBSCRIPTION_ARTICLES,
				NotificationNames.GREADER_ARTICLES_SUCCESS
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var notificationName:String = notification.getName();
			var notificationBody:Object = notification.getBody();
			
			switch(notificationName)
			{
				case NotificationNames.REQUEST_SUBSCRIPTION_ARTICLES:
					//TODO: Request Specific Subscription
					this.subscription = notificationBody as Subscription;
					readerClient.getArticles({});
					break;
				case NotificationNames.GREADER_ARTICLES_SUCCESS:
					this.reloadArticles();
					break;
			}
		}
		
		/**
		 * View Logic
		 **/
		
		private function reloadArticles():void
		{
			var articles:Array = articlesProxy.articleBySubscription(this.subscription);
			this.view.articlesList.dataProvider = new DataProvider(articles);
		}
		
		/**
		 * Getters and Setters
		 **/
		
		public function get view():ArticlesView
		{
			return this.getViewComponent() as ArticlesView;
		}
		
		private function get readerClient():GReaderClient
		{
			return facade.retrieveProxy( GReaderProxy.NAME ).getData() as GReaderClient;
		}
		
		private function get articlesProxy():ArticlesProxy
		{
			return facade.retrieveProxy( ArticlesProxy.NAME ) as ArticlesProxy;
		}
	}
}