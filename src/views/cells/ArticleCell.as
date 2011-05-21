package views.cells
{
	import flash.display.Shape;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.casalib.util.DateUtil;
	
	import puremvc.vo.Article;
	
	import qnx.ui.display.Image;
	import qnx.ui.listClasses.AlternatingCellRenderer;
	import qnx.ui.listClasses.CellRenderer;
	import qnx.ui.skins.SkinStates;
	import qnx.ui.text.Label;
	
	import utils.LabelUtil;
	
	public class ArticleCell extends AlternatingCellRenderer
	{
		private var dateLabel:Label;
		private var titleLabel:Label;
		private var descriptionLabel:Label;
		private var maskShape:Shape;
		private var starredImage:Image;
		
		private var dateUpColor:uint = 0x000000;
		private var dateDownColor:uint = 0xFFFFFF;
		
		private var titleUpColor:uint = 0x000000;
		private var titleDownColor:uint = 0xFFFFFF;
		
		private var descriptionUpColor:uint = 0x474747;
		private var descriptionDownColor:uint = 0xFFFFFF;
		
		public function ArticleCell()
		{
			var dateFormat:TextFormat = new TextFormat(null, 14, dateUpColor, false);
			dateFormat.align = TextFormatAlign.RIGHT;
			var titleFormat:TextFormat = new TextFormat(null, 18, titleUpColor, false);
			var descriptionFormat:TextFormat = new TextFormat(null, 15, descriptionUpColor, false);			
			
			this.dateLabel = new Label();
			this.dateLabel.format = dateFormat;
			this.dateLabel.mouseEnabled = false;
			this.dateLabel.mouseChildren = false;
			this.dateLabel.height = 20;
			this.addChild( this.dateLabel );
			
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
			
			this.starredImage = new Image();
			this.starredImage.setImage("assets/star.png");
			this.starredImage.x = 8;
			this.starredImage.y = 5;	
			this.addChild( this.starredImage );
			
			super();
			
			this.label.visible = false;
		}
		
		private function calculateTextSize():void
		{
			var topMargin:uint = 5;
			var bottomMargin:uint = 0;
			var horizontalMargin:uint = 5;
			var gap:uint = 0;
			
			var maxWidth:Number = width - 2*horizontalMargin;
			var textHeight:Number;
			
			textHeight = LabelUtil.labelHeightForText(this.titleLabel.text, maxWidth, this.titleLabel.format);
			
			this.dateLabel.x = horizontalMargin;
			this.dateLabel.y = topMargin;
			this.dateLabel.width = width - 2*horizontalMargin;
			
			this.titleLabel.x = horizontalMargin;
			this.titleLabel.y = this.dateLabel.y + this.dateLabel.height + gap;
			this.titleLabel.wordWrap = true;
			this.titleLabel.width = width - 2*horizontalMargin;
			this.titleLabel.height = Math.min(height, textHeight);
			
			this.descriptionLabel.x = horizontalMargin;
			this.descriptionLabel.y = this.titleLabel.y + this.titleLabel.height + gap;
			this.descriptionLabel.wordWrap = true;
			this.descriptionLabel.width = width - 2*horizontalMargin;
			this.descriptionLabel.height = height - bottomMargin - this.descriptionLabel.y;
			
			this.descriptionLabel.visible = (this.descriptionLabel.y < height);
		}
		
		override public function set data(value:Object):void
		{
			var article:Article = value as Article;
			
			this.titleLabel.htmlText = article.label;
			this.descriptionLabel.htmlText = article.description;
			
			this.dateLabel.text = DateUtil.formatDate(article.date, "h:i A");
			this.alpha = article.isRead ? 0.5 : 1;
			this.starredImage.visible = article.isStarred;
			
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
			
			format = this.dateLabel.format;
			format.color = (value == SkinStates.UP) ? dateUpColor : dateDownColor;
			this.dateLabel.format = format;
			
			super.setState(value);
		}
	}
}