package puremvc.vo
{
	import flash.display.BitmapData;

	public class Subscription extends BaseModel
	{
		public var id:String;
		public var title:String;
		public var categories:Array;
		public var sortid:String;
		public var htmlUrl:String;
		public var unreadCount:uint;
		
		public function Subscription() {}
		
		override public function classByLabel(label:String):Class
		{
			if (label == "categories")
				return Tag;
			
			return null;
		}
		
		public function get label():String
		{
			return this.title;
		}
	}
}