package views.cells
{
	import flash.display.Shape;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import puremvc.vo.Article;
	
	import qnx.ui.listClasses.AlternatingCellRenderer;
	import qnx.ui.listClasses.CellRenderer;
	import qnx.ui.skins.SkinStates;
	import qnx.ui.text.Label;
	
	public class ArticleCell extends AlternatingCellRenderer
	{
		private var titleLabel:Label;
		private var descriptionLabel:Label;
		private var maskShape:Shape;
		
		private var titleUpColor:uint = 0x000000;
		private var titleDownColor:uint = 0xFFFFFF;
		private var descriptionUpColor:uint = 0x474747;
		private var descriptionDownColor:uint = 0xFFFFFF;
		
		public function ArticleCell()
		{
			var titleFormat:TextFormat = new TextFormat(null, 18, titleUpColor, false);
			var descriptionFormat:TextFormat = new TextFormat(null, 15, descriptionUpColor, false);
			
			this.titleLabel = new Label();
			this.titleLabel.format = titleFormat;
			this.titleLabel.mouseEnabled = false;
			this.titleLabel.mouseChildren = false;
			this.addChild( this.titleLabel );
			
			this.descriptionLabel = new Label();
			this.descriptionLabel.format = descriptionFormat;
			this.descriptionLabel.mouseEnabled = false;
			this.descriptionLabel.mouseChildren = false;
			this.addChild( this.descriptionLabel );
			
			super();
			
			this.label.visible = false;
		}
		
		private function calculateTextSize():void
		{
			var topMargin:uint = 5;
			var bottomMargin:uint = 0;
			var horizontalMargin:uint = 5;
			var gap:uint = 0;
			
			this.titleLabel.x = horizontalMargin;
			this.titleLabel.y = topMargin;
//			this.descriptionLabel.wordWrap = true;
//			this.descriptionLabel.autoSize = TextFieldAutoSize.LEFT;
			this.titleLabel.width = width - 2*horizontalMargin;
			
			
			this.descriptionLabel.x = horizontalMargin;
			this.descriptionLabel.y = 30;//this.titleLabel.y + this.titleLabel.height + gap;
			this.descriptionLabel.wordWrap = true;
//			this.descriptionLabel.autoSize = TextFieldAutoSize.LEFT;
			this.descriptionLabel.width = width - 2*horizontalMargin;
			this.descriptionLabel.height = height - bottomMargin - this.descriptionLabel.y;
			
		}
		
		override public function set data(value:Object):void
		{
			var article:Article = value as Article;
			
			this.titleLabel.text = article.label;
			this.descriptionLabel.htmlText = article.desription;
			
			calculateTextSize();
			
			super.data = value;
		}
		
		override protected function setState(value:String):void
		{
			var format:TextFormat;
			format = this.titleLabel.format;
			format.color = (value == SkinStates.UP) ? titleUpColor : titleDownColor;
			this.titleLabel.format = format;
			
			format = this.descriptionLabel.format;
			format.color = (value == SkinStates.UP) ? descriptionUpColor : descriptionDownColor;
			this.descriptionLabel.format = format;
			
			super.setState(value);
		}
	}
}