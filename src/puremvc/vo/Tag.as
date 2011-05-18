package puremvc.vo
{
	public class Tag extends BaseModel
	{
		public var id:String;
		public var label:String;
		
		public function Tag(){}
		
		public function get title():String
		{
			if(this.label)
			{
				//Return last part
				return label.split("/").pop();
			}
			
			return null;
		}
	}
}