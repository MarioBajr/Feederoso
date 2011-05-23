package puremvc.mediator
{
	
	import com.adobe.utils.DictionaryUtil;
	
	import flash.net.dns.AAAARecord;
	import flash.utils.Dictionary;
	
	import org.casalib.util.DateUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.NotificationNames;
	import puremvc.proxy.ArticlesProxy;
	import puremvc.proxy.GReaderProxy;
	import puremvc.service.GReaderClient;
	import puremvc.vo.Article;
	import puremvc.vo.Subscription;
	
	import qnx.ui.data.DataProvider;
	import qnx.ui.data.SectionDataProvider;
	import qnx.ui.events.ListEvent;
	import qnx.ui.listClasses.ICellRenderer;
	
	import utils.ObjectUtil;
	
	import views.ArticleListView;
	
	public class ArticleListMediator extends Mediator
	{
		private var selectedIndexPath:Object;
		private var subscription:Subscription;
		private var lastIdentifier:String;
		
		public function ArticleListMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			this.view.articlesList.addEventListener(ListEvent.ITEM_CLICKED, onItemClicked);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( ArticleListMediator );
		}
		
		/**
		 * Override Methods
		 **/
		
		override public function listNotificationInterests():Array
		{
			return [
				NotificationNames.REQUEST_SUBSCRIPTION_ARTICLES,
				NotificationNames.GREADER_ARTICLES_SUCCESS,
				NotificationNames.ARTICLE_ISSTARRED_CHANGED
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var notificationName:String = notification.getName();
			var notificationBody:Object = notification.getBody();
			
			switch(notificationName)
			{
				case NotificationNames.REQUEST_SUBSCRIPTION_ARTICLES:
					this.subscription = notificationBody as Subscription;
					this.view.setTitleText(this.subscription.title);
					readerClient.getArticles({feed:this.subscription.id});
					this.clearArticles();
					break;
				case NotificationNames.GREADER_ARTICLES_SUCCESS:
					this.reloadArticles();
					break;
				case NotificationNames.ARTICLE_ISSTARRED_CHANGED:
					var sectionsDP:SectionDataProvider = this.view.articlesList.dataProvider as SectionDataProvider;
					var section:Object = sectionsDP.getItemAt( selectedIndexPath.section );
					sectionsDP.updateChildInItemAt( section, notificationBody, selectedIndexPath.row);
					break;
			}
		}
		
		/**
		 * View Logic
		 **/
		
		private function reloadArticles():void
		{
			var articles:Array = articlesProxy.articles;
			var sectionsByDay:Dictionary = new Dictionary();
			var articlePerSections:Dictionary = new Dictionary();
			
			for each (var article:Article in articles)
			{
				var date:Date = article.date;
				var dateString:String = DateUtil.formatDate(date, "l, M j, Y");
				
				sectionsByDay[dateString] = {label:dateString, dateNum:date.getTime()};
				
				if(!articlePerSections[dateString])
					articlePerSections[dateString] = new Array();
				
				articlePerSections[dateString].push(article);
			}
			
			var sections:Array = DictionaryUtil.getValues( sectionsByDay );
			sections.sortOn("dateNum", Array.DESCENDING);
			
			var sectionDP:SectionDataProvider = new SectionDataProvider();
			for each(var section:Object in sections)
			{
				sectionDP.addItem(section);
				
				for each (article in articlePerSections[section.label])
				{
					sectionDP.addChildToItem(article, section);
				}
			}
			
			this.view.articlesList.dataProvider = sectionDP;
		}
		
		private function clearArticles():void
		{
			this.lastIdentifier = null;
			this.selectedIndexPath = null;
			this.view.articlesList.selectedItem = null;
			this.view.articlesList.dataProvider = new SectionDataProvider();
		}
		
		private function onItemClicked(event:ListEvent):void
		{
			if(event.data is Article)
			{
				var article:Article = event.data as Article;
				
				if(lastIdentifier != article.id)
				{
					selectedIndexPath = {section:event.section, row:event.index};
					facade.sendNotification( NotificationNames.SHOW_ARTICLE_VIEW, article);
					
					if(!article.isRead)
					{
						article.isRead = true;
						article.syncronize(readerClient);
						event.cell.data = event.data;//Force Update
						this.subscription.unreadCount--;
						sendNotification( NotificationNames.ARTICLE_ISREAD_CHANGED, article);
						sendNotification( NotificationNames.SUBSCRIPTION_READCOUNT_CHANGED, subscription);
					}
				}
				
				lastIdentifier = article.id;
			}
		}
		
		/**
		 * Getters and Setters
		 **/
		
		public function get view():ArticleListView
		{
			return this.getViewComponent() as ArticleListView;
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