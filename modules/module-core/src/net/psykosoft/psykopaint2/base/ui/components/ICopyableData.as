package net.psykosoft.psykopaint2.base.ui.components
{
	public interface ICopyableData
	{
		function copyData( data:Object ):void;
		
		function copyDataProperty( data:Object, propertyID:String ):void;
		
	}
}