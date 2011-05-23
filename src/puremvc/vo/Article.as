package puremvc.vo
{
	
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	
	import org.casalib.util.DateUtil;
	import org.puremvc.as3.patterns.facade.Facade;
	
	import puremvc.ApplicationFacade;
	import puremvc.service.GReaderClient;
	
	import utils.ObjectUtil;

	public class Article extends BaseModel
	{
		public var data:Object;
		private var _date:Date;
		
		private var _isReadRemote:Boolean;
		private var _isReadRemoteFetched:Boolean;
		private var _isRead:Boolean;
		
		private var _isStarredRemote:Boolean;
		private var _isStarredRemoteFetched:Boolean;
		private var _isStarred:Boolean;
		
		public function Article()
		{
			this._isReadRemoteFetched = false;
			this._isStarredRemoteFetched = false;
		}
		
		public function get id():String
		{
			if(this.data)
			{
				return this.data.id.toString();
			}
			return null;
		}
		
		public function get label():String
		{
			if(this.data)
			{
				return this.data.title.toString();
			}
			return null;
		}
		
		public function get description():String
			
		{
			if(this.data)
			{
				if(this.data.hasOwnProperty("summary"))
					return this.data.summary.toString();
				
				if(this.data.hasOwnProperty("content"))
					return this.data.content.toString();
			}
			
			ObjectUtil.deepTrace(this.data);
			return null;
		}
		
		public function get dateString():String
		{
			if(this.data)
			{
				if(this.data.hasOwnProperty("published"))
					return this.data.published.toString();
			}
			return null;
		}
		
		public function get date():Date
		{
			//Store for faster sorting property
			if(!_date)
				_date = DateUtil.iso8601ToDate( this.dateString );
				
			return _date;
		}
		
		public function get link():String
		{
			if(this.data)
			{
				if(this.data.hasOwnProperty("link"))
				{
					if(this.data.link is ArrayCollection && this.data.link.length > 0)
						if(this.data.link[0].hasOwnProperty("href"))
							return this.data.link[0].href.toString();
					
					if(this.data.link.hasOwnProperty("href"))
						return this.data.link.href.toString();
				}
			}
			
			ObjectUtil.deepTrace(this.data);
			
			return null;
		}
		
		public function set isRead(value:Boolean):void
		{
			_isRead = value;
		}
		
		public function get isRead():Boolean
		{
			if(!_isReadRemoteFetched && this.data)
			{
				if(this.data.hasOwnProperty("category") && this.data.category.length > 0)
				{
					var tags:ArrayCollection = this.data.category;
					var filteredTags:Array = tags.source.filter(isReadTag);
					_isReadRemote = (filteredTags.length > 0);
					_isRead = _isReadRemote;
					_isReadRemoteFetched = true;
				}
			}
			
			return _isRead;
		}
		
		public function set isStarred(value:Boolean):void
		{
			_isStarred = value;
		}
		
		public function get isStarred():Boolean
		{
			if(!_isStarredRemoteFetched && this.data)
			{
				if(this.data.hasOwnProperty("category") && this.data.category.length > 0)
				{
					var tags:ArrayCollection = this.data.category;
					var filteredTags:Array = tags.source.filter(isStarredTag);
					_isReadRemote = (filteredTags.length > 0);
					_isStarred = _isReadRemote;
					_isStarredRemoteFetched = true;
				}
			}
			
			return _isStarred;
		}
		
		/**
		 *  Helpers
		 **/
		
		private function isReadTag(item:*, index:int, array:Array):Boolean
		{
			return (item.label == "read");
		}
		
		private function isStarredTag(item:*, index:int, array:Array):Boolean
		{
			return (item.label == "starred");
		}
		
		/**
		 *  Syncronize
		 **/
		
		public function syncronize(readerClient:GReaderClient):void
		{
			var willAdd:uint;
			if(_isReadRemote != _isRead)
			{
				willAdd = _isRead ? 0 : 1;
				readerClient.tagArticle({i:this.id, t:0, r:willAdd}, null);
				_isReadRemote = _isRead;
			}
			
			if(_isStarredRemote != isStarred)
			{
				willAdd = isStarred ? 0 : 1;
				readerClient.tagArticle({i:this.id, t:2, r:willAdd}, null);
				_isStarredRemote = isStarred;
			}
		}
	}
}