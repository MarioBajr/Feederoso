package puremvc.mediator
{
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextFormat;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.ArticlesProxy;
	import puremvc.vo.Article;
	
	import qnx.media.QNXStageWebView;
	
	import utils.ObjectUtil;
	
	import views.ArticleView;
	
	public class ArticleMediator extends Mediator
	{
		private var article:Article;
		
		public function ArticleMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			this.view.titleView.addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
			this.view.titleView.addEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
			this.view.closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			this.view.setWebViewMode(false);
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
					this.article = notificationBody as Article;
					this.view.setArticle(article);
					break;
			}
		}
		
		/**
		 *  View  Logic
		 **/
		
		private function onTouchBegin(event:MouseEvent):void
		{
			var format:TextFormat = this.view.title.format;
			format.color = 0xFFFFFF;
			this.view.title.format = format;
			
			this.view.titleView.graphics.clear();
			this.view.titleView.graphics.beginFill( 0x0000FF );
			this.view.titleView.graphics.drawRect(0, 0, 1, 1);
			this.view.titleView.graphics.endFill();
		}
		
		private function onTouchEnd(event:MouseEvent):void
		{	
			var format:TextFormat = this.view.title.format;
			format.color = 0x000000;
			this.view.title.format = format;
			
			this.view.titleView.graphics.clear();
			this.view.titleView.graphics.beginFill( 0xcccccc );
			this.view.titleView.graphics.drawRect(0, 0, 1, 1);
			this.view.titleView.graphics.endFill();
			
			if(this.article.link)
			{
				facade.sendNotification( NotificationNames.EXPANDED_ARTICLE_VIEW );
				this.view.setWebViewMode( true );
				trace(this.article.link);
				this.view.webView.loadURL( this.article.link );
			}
		}
		
		private function onCloseClick(event:MouseEvent):void
		{
			facade.sendNotification( NotificationNames.DEFAULT_ARTICLE_VIEW );
			this.view.setWebViewMode(false);
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