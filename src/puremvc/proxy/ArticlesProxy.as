package puremvc.proxy
{
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import puremvc.vo.Article;
	import puremvc.vo.Subscription;
	
	import utils.ObjectUtil;
	
	public class ArticlesProxy extends Proxy
	{
		public var articles:Array;
		
		public function ArticlesProxy()
		{
			super(NAME);
		}
		
		public static function get NAME():String
		{
			return ObjectUtil.getClassName( ArticlesProxy );
		}
		
		override public function setData(data:Object):void
		{
			super.setData( data );
			
			this.articles = new Array();
			for each (var obj:Object in data.feed.entry)
			{
				var article:Article = new Article();
				article.data = obj;
				
				this.articles.push( article );
			}
		}
		
		public function articleBySubscription(subscription:Subscription):Array
		{
			var filterBySubscription:Function = function(element:*, index:int, arr:Array):Boolean
			{
				var article:Article = element as Article;
				var id:String = article.data.source.id.toString();
				var index:int = id.indexOf(subscription.id);
				
				return (index >= 0);
			}
			
			return this.articles.filter(filterBySubscription);
		}
	}
}