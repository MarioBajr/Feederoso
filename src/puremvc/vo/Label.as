package puremvc.vo
{
	public class Label extends BaseModel
	{
		public var label:String;
		
		public function Label(){}
		
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