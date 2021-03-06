package views.cells
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.casalib.util.SingletonUtil;
	
	import puremvc.vo.Subscription;
	
	import qnx.ui.display.Image;
	import qnx.ui.listClasses.AlternatingCellRenderer;
	import qnx.ui.skins.SkinStates;
	import qnx.ui.text.Label;
	import qnx.utils.ImageCache;
	
	import utils.ObjectUtil;
	
	public class SubscriptionCell extends AlternatingCellRenderer
	{
		private var titleLabel:Label;
		private var countLabel:Label;
		private var countView:Shape;
		private var favicon:Image;
		
		private var titleUpColor:uint = 0x000000;
		private var titleDownColor:uint = 0xFFFFFF;
		
		private var countUpColor:uint = 0xFFFFFF;
		private var countDownColor:uint = 0x5276E5;
		
		private var countViewUpColor:uint = 0x888888;
		private var countViewDownColor:uint = 0xFFFFFF;
		
		private const MARGIN:uint = 10;
		private const FAVICON_EDGE:uint = 12;
		private const GAP:uint = 5;
		private const BOX_MARGIN_H:uint = 4;
		private const BOX_MARGIN_V:int = -2;
		
		private const FAVICON_SERVICE:String = "http://geticon.org/of/";
		
		public function SubscriptionCell()
		{
			this.favicon = new Image();
			this.favicon.x = 5;
			this.favicon.y = 15;
			this.favicon.addEventListener(Event.COMPLETE, onLoadComplete);
			this.favicon.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
			this.addChild(favicon);
			
			var format:TextFormat;
			
			format = new TextFormat(null, 18, titleUpColor, false);
			
			this.titleLabel = new Label();
			this.titleLabel.format = format;
			this.titleLabel.mouseEnabled = false;
			this.titleLabel.mouseChildren = false;
			this.titleLabel.y = 10;
			this.addChild( this.titleLabel );
			
			this.countView = new Shape();
			this.addChild( this.countView );
			
			
			format = new TextFormat(null, 16, countUpColor, true)
			
			this.countLabel = new Label();
			this.countLabel.format = format;
			this.countLabel.mouseEnabled = false;
			this.countLabel.mouseChildren = false;
			this.countLabel.y = 10;
			this.countLabel.height = 25;
			this.addChild( this.countLabel );
			
			super();
			
			this.label.visible = false;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			var subscription:Subscription = value as Subscription;
			
			this.titleLabel.text = subscription.label;
			
			var count:uint = subscription.unreadCount;
			
			if(count > 0)
			{
				this.countView.visible = true;
				this.countLabel.visible = true;
				this.countLabel.text = subscription.unreadCount.toString();
				
				this.countLabel.autoSize = TextFieldAutoSize.LEFT;
				this.countLabel.x = this.width - this.countLabel.textWidth - BOX_MARGIN_H - MARGIN;
				
				this.setState( this.state );//Update Color
			}
			else
			{
				this.countView.visible = false;
				this.countLabel.visible = false;
				this.countLabel.x = this.width - MARGIN;
			}
			
			var parts:Array = subscription.htmlUrl.replace("http://", "").split("/");
			var path:String = FAVICON_SERVICE+ "http://" + parts[0];
				
			this.favicon.setImage(path);
			
			this.titleLabel.x = this.favicon.x + FAVICON_EDGE + MARGIN;
			this.titleLabel.width = this.countLabel.x - GAP - BOX_MARGIN_H - this.titleLabel.x;
		}
		
		private function drawCountBox(color:uint):void
		{
			this.countView.x = this.countLabel.x - BOX_MARGIN_H;
			this.countView.y = this.countLabel.y - BOX_MARGIN_V;
			var w:Number = this.countLabel.textWidth + 2*BOX_MARGIN_H + 5;//Alignment wrong, need this
			var h:Number = this.countLabel.height + 2*BOX_MARGIN_V;
			
			this.countView.graphics.clear();
			this.countView.graphics.beginFill( color );
			this.countView.graphics.drawRoundRect(0, 0, w, h, h);
			this.countView.graphics.endFill();
		}
		
		override protected function setState(value:String):void
		{
			var format:TextFormat;
			format = this.titleLabel.format;
			format.color = (value == SkinStates.UP) ? titleUpColor : titleDownColor;
			this.titleLabel.format = format;
			
			format = this.countLabel.format;
			format.color = (value == SkinStates.UP) ? countUpColor : countDownColor;
			this.countLabel.format = format;
			
			var color:uint = (value == SkinStates.UP) ? countViewUpColor : countViewDownColor;
			this.drawCountBox(color);
			
			super.setState(value);
		}
		
		private function onLoadComplete(event:Event):void
		{
			this.favicon.cache = SingletonUtil.singleton(ImageCache);
			//Load Complete
		}
		
		private function onImageError(event:IOErrorEvent):void
		{
			//Do Nothing
		}
	}
}