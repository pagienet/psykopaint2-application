package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;

	public class PencilBrushShape extends AbstractBrushShape
	{
		private var _hardness : Number = .01;
		private var _grain : Number = 0.9;
		private var _coarseness : Number = .4;

		public function PencilBrushShape(context3D : Context3D)
		{
			super(context3D, "pencil", 1);
			_variationFactors[0] = 1;
			_variationFactors[1] = 1;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			_rotationRange = 0;

			size = 16;
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;

			var upperLimit : uint = 255*(0.9-_hardness*0.8),
				bottomLimit : uint = upperLimit-_grain*upperLimit;
			var brushMap : BitmapData = new BitmapData(size, size, true, 0xff00000000);
			var blur : BlurFilter = new BlurFilter((1-_coarseness)*2, (1-_coarseness)*2, BitmapFilterQuality.HIGH);
			brushMap.noise(1000, bottomLimit, upperLimit, 7, true);
			brushMap.applyFilter(brushMap, brushMap.rect, new Point(), blur);

			uploadMips(_textureSize, brushMap, texture);

			if (brushMap) brushMap.dispose();
		}
	}
}



