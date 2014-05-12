package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class RenderTextureBrushShape extends AbstractBrushShape
	{
		
		public static const NAME:String = "render";

		
		public var _brushMap : BitmapData;
		private const origin:Point = new Point();
		
		public function RenderTextureBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, 1,1024 * CoreSettings.GLOBAL_SCALING,1,1);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			
			_brushMap = new TrackedBitmapData(size, size, true, 0);
			texture.uploadFromBitmapData(_brushMap, 0);
		}

		override protected function updateTexture(texture : Texture, automatic:Boolean = true ) : void
		{
			if (!automatic) texture.uploadFromBitmapData(_brushMap, 0);
		}
		
		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			uploadMips(size,_brushMap,texture);
			//texture.uploadFromBitmapData(_brushMap, 0);
		}
	}
}
