package utils
{
	public class StringUtil
	{
		public static function isEmpty(value:String):Boolean
		{
			return (value == null || value == "" || value == "undefined");
		}
	}
}