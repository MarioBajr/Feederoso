package puremvc.vo
{
	import flash.utils.Dictionary;
	

	public class BaseModel
	{
		public function BaseModel(){}
		
		/**
		 *  SetUp Model
		 **/
		
		public function setUpModelWithXML(xml:XML):void
		{
			var stringList:XMLList = xml.string;
			
			for each(var item:XML in xml.children())
			{	
				var kind:String = item.localName();
				var label:String = item.attribute("name");
				
				//Se o objeto não possuir a propriedade pula para o proximo tem
				if (!this.hasOwnProperty(label))
					continue;
				
				switch(kind)
				{
					case "string":
						this[label] = item.toString();
						break;
					case "number":
						this[label] = int( item.toString() );
						break;
					case "list":
						this.setUpList( item );
						break;
				}
			}
		}
		
		private function setUpList( xml:XML ):void
		{
			var label:String = xml.attribute("name");
			var ModelClass:Class = classByLabel( label );
			this[label] = new Array();
			
			for each(var item:XML in xml.children())
			{
				var modelRef:BaseModel = new ModelClass() as BaseModel;
				modelRef.setUpModelWithXML( item );
				this[label].push(modelRef);
			}
		}
		
		//Override Me!
		public function classByLabel(label:String):Class
		{
			return null;
		}
	}
}