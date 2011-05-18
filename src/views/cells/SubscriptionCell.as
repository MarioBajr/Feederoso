package views.cells
{
	import flash.text.TextFormat;
	
	import qnx.ui.listClasses.AlternatingCellRenderer;
	import qnx.ui.skins.SkinStates;
	
	public class SubscriptionCell extends AlternatingCellRenderer
	{
		public function SubscriptionCell()
		{
			super();

			setTextFormatForState( new TextFormat(null, 18, 0x000000), SkinStates.UP);
			setTextFormatForState( new TextFormat(null, 18, 0xFFFFFF), SkinStates.SELECTED);
		}
	}
}