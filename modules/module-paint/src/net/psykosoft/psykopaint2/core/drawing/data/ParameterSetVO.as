package net.psykosoft.psykopaint2.core.drawing.data
{
	public class ParameterSetVO
	{
		public var brushName:String;
		public var parameters:Vector.<PsykoParameter>;
		
		public function ParameterSetVO( brushName:String )
		{
			this.brushName = brushName;
			parameters = new Vector.<PsykoParameter>();
				
		}
	}
}