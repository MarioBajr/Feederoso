package puremvc.proxy
{
	import org.puremvc.as3.patterns.proxy.Proxy;
	import puremvc.service.GReaderClient;
	
	public class GReaderProxy extends Proxy
	{
		public static const NAME:String = "GReaderProxy";
		
		public function GReaderProxy()
		{
			super(NAME, new GReaderClient());
		}
		
		public function get readerClient():GReaderClient
		{
			return this.getData() as GReaderClient;
		}
	}
}