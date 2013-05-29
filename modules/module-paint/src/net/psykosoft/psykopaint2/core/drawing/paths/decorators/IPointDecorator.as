package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public interface IPointDecorator
	{
		function process( points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean ):Vector.<SamplePoint>
		function getParameterSet( path:Array ):XML
		function updateParametersFromXML( xml:XML):void;
		function hasActivePoints():Boolean;
		function clearActivePoints():void;
		function compare( points:Vector.<SamplePoint>, manager:PathManager ):Vector.<Vector.<SamplePoint>>
			
	}
}