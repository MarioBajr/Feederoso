package puremvc.vo
{
	public class Subscription extends BaseModel
	{
		public var title:String;
		public var categories:Array;
		public var sortid:String;
		public var htmlUrl:String;
		
		public function Subscription() {}
		
		override public function classByLabel(label:String):Class
		{
			if (label == "categories")
				return Label;
			
			return null;
		}
		
		public function get label():String
		{
			return this.title;
		}
	}
}