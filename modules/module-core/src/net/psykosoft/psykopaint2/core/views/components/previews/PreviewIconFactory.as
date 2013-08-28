package net.psykosoft.psykopaint2.core.views.components.previews
{
	public class PreviewIconFactory
	{
		private static var IconClasses:Vector.<Class> = Vector.<Class>([
			AlphaPreview,
			BrightnessPreview,
			DepthPreview,
			LengthPreview,
			OutlinePreview,
			PrecisionPreview,
			SaturationPreview,
			SizePreview,
			SurfaceInfluencePreview
		]);
		
		
		public function PreviewIconFactory()
		{
		}
		
		public static function getPreviewIcon(index:int):AbstractPreview
		{
			return new IconClasses[index]();
		}
	}
}