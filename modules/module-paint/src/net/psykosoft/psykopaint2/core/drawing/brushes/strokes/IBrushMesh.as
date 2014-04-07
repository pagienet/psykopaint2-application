package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.TextureProxy;

	public interface IBrushMesh
	{
		// call when stroke is finished, returns true or false depending if brush was actually valid
		function finalize() : Boolean;

		function init(context3d : Context3D) : void;

		function get numTriangles() : int;

		function getBounds() : Rectangle;

		function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void;

		function append( appendVO:StrokeAppendVO ):void;

		function get bakedTexture() : TextureProxy;
		function set bakedTexture(value : TextureProxy) : void;

		function clear() : void;

		function drawNormalsAndSpecular(context3d : Context3D, canvas : CanvasModel, shininess : Number, glossiness : Number, bumpiness : Number, influence : Number) : void;
	}
}
