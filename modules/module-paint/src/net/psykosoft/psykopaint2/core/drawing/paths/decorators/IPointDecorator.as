package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	public interface IPointDecorator
	{
		function process( points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean ):Vector.<SamplePoint>
		function getParameterSetAsXML( path:Array ):XML
		function getParameterSet( vo:ParameterSetVO, showInUIOnly:Boolean ):void
		function getParameterByPath(path:Array):PsykoParameter;
		function updateParametersFromXML( xml:XML):void;
		function hasActivePoints():Boolean;
		function clearActivePoints():void;
		function compare( points:Vector.<SamplePoint>, manager:PathManager ):Vector.<Vector.<SamplePoint>>
		function get active():Boolean
		function set active( value:Boolean):void
		
		
	}
}