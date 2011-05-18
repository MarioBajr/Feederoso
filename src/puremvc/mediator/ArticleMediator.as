package puremvc.mediator
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.ArticlesProxy;
	import puremvc.vo.Article;
	
	import utils.ObjectUtil;
	
	import views.ArticleView;
	
	public class ArticleMediator extends Mediator
	{
		public function ArticleMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( ArticleMediator );
		}
		
		/**
		 * Override Methods
		 **/
		
		override public function listNotificationInterests():Array
		{
			return [
				NotificationNames.SHOW_ARTICLE_VIEW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var notificationName:String = notification.getName();
			var notificationBody:Object = notification.getBody();
			
			switch(notificationName)
			{
				case NotificationNames.SHOW_ARTICLE_VIEW:
					var article:Article = notificationBody as Article;
					this.view.setArticle(article.label, article.desription);
					break;
			}
		}
		
		/**
		 * Getters and Setters
		 **/
		
		public function get view():ArticleView
		{
			return this.getViewComponent() as ArticleView;
		}
		
		private function get articlesProxy():ArticlesProxy
		{
			return facade.retrieveProxy( ArticlesProxy.NAME ) as ArticlesProxy;
		}
	}
}