package puremvc.vo
{
	
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	
	import org.casalib.util.DateUtil;
	
	import utils.ObjectUtil;

	public class Article extends BaseModel
	{
		public var data:Object;
		private var _date:Date;
		
		public function Article(){}
		
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
	}
}