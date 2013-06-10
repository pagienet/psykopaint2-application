package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;

	public interface IPathEngine
	{
		function clear():void;
		function addFirstPoint( point:Point, pressure:Number = -1 ):void;
		function addPoint( point:Point, pressure:Number = -1, force:Boolean = false ):Boolean;
		function addXY( x:Number, y:Number, pressure:Number = -1, force:Boolean = false ):Boolean;
		function getPointAt( index:int ):SamplePoint;
		function clone( startIndex:int = 0, count:int = -1 ):IPathEngine;
		function update( forceUpdate:Boolean = false ):Vector.<SamplePoint>;
		function updateParametersFromXML(xml:XML):void;
		function getParameterSet( path:Array ):XML;
		
		function get type():int;
		function get minSamplesPerStep():PsykoParameter;
		function set minSamplesPerStep( value:PsykoParameter ):void;
		function get outputStepSize():PsykoParameter;
		function set outputStepSize( value:PsykoParameter ):void;
		function get pointCount():int;
		function get sampledPoints():Vector.<SamplePoint>;
		function set sendTaps( value:Boolean ):void;
		function get sendTaps():Boolean;
		
	}
}