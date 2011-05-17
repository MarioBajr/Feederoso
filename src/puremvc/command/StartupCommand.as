package puremvc.command
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import puremvc.proxy.GReaderProxy;
	
	public class StartupCommand extends SimpleCommand
	{	
		override public function execute(notification:INotification):void
		{
			
		}
	}
}