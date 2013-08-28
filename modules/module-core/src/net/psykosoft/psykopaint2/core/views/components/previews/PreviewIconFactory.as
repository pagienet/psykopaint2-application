package net.psykosoft.psykopaint2.core.views.components.previews
{
	public class PreviewIconFactory
	{
		
		public static const PREVIEW_ALPHA:String = "alpha";
		public static const PREVIEW_BRIGHTNESS:String = "Brightness";
		public static const PREVIEW_DEPTH:String = "Depth";
		public static const PREVIEW_LENGTH:String = "Length";
		public static const PREVIEW_OUTLINE:String = "Outline";
		public static const PREVIEW_PRECISION:String = "Precision";
		public static const PREVIEW_SATURATION:String = "Saturation";
		public static const PREVIEW_SIZE:String = "Size";
		public static const PREVIEW_SURFACE_INFLUENCE:String = "SurfaceInfluence";
		public static const PREVIEW_ERASER_STYLE:String = "EraserStyle";
		public static const PREVIEW_PAINTBRUSH_STYLE:String = "PaintbrushStyle";
		public static const PREVIEW_SHAPE_STYLE:String = "ShapeStyle";
		
		private static var IconClasses:Vector.<Class> = Vector.<Class>([
			AlphaPreview,
			BrightnessPreview,
			DepthPreview,
			LengthPreview,
			OutlinePreview,
			PrecisionPreview,
			SaturationPreview,
			SizePreview,
			SurfaceInfluencePreview,
			EraserStylePreview,
			PaintbrushStylePreview,
			ShapeStylePreview
		]);
		
		private static var id2Index:Array = [
			PREVIEW_ALPHA,
			PREVIEW_BRIGHTNESS,
			PREVIEW_DEPTH,
			PREVIEW_LENGTH,
			PREVIEW_OUTLINE,
			PREVIEW_PRECISION,
			PREVIEW_SATURATION,
			PREVIEW_SIZE,
			PREVIEW_SURFACE_INFLUENCE,
			PREVIEW_ERASER_STYLE,
			PREVIEW_PAINTBRUSH_STYLE,
			PREVIEW_SHAPE_STYLE
		];
		
		public function PreviewIconFactory()
		{
		}
		
		public static function getPreviewIcon(id:String):AbstractPreview
		{
			if ( id != null )
				return new IconClasses[id2Index.indexOf(id)]();
			else {
				trace("WARNING - no preview icon id assigned!")
				return new SizePreview();
			}
		}
	}
}