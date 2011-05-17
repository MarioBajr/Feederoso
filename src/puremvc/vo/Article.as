package puremvc.vo
{
	public class Article extends BaseModel
	{
		public var data:Object;
		
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
		
		
	}
}