package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;

	import org.osflash.signals.Signal;

	public interface SimulationMesh extends IBrushMesh
	{
		function get buffersFullSignal():Signal;

		function get stationaryTriangleCount():int;

		function drawMesh(context3d : Context3D, uvMode : int, numTriangles : int = -1, useColor : Boolean = true, offset : int = 0) : void;
		function appendStationary() : void;
	}
}
