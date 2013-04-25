package net.psykosoft.psykopaint2.app.view.components.combobox
{
	public class PaperListItemVO
	{
		public var id:String;
		public var label:String;
		public var odd:Boolean=false;

		private var _dataObject:Object;
		
		public function PaperListItemVO(dataObject:Object = null)
		{
			this._dataObject = dataObject; 
			if(dataObject){
				id = dataObject['id'];
				label = dataObject['label'];
				odd = (dataObject['odd'])?true:false;
			}
			
		}
	}
}