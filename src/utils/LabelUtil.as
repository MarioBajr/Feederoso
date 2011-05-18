package utils
{
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import qnx.ui.text.Label;

	public class LabelUtil
	{
		public static function labelHeightForText(text:String, width:Number, format:TextFormat=null):Number
		{
			var label:Label = new Label();
			if (format)
				label.format = format;
			label.htmlText = text;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.width = width;
			
			return label.textHeight + 5;
		}
	}
}