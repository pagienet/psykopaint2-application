package net.psykosoft.psykopaint2.core.views.components.previews
{
	import flash.display.MovieClip;

	public class PreviewIconFactory
	{
		private static var IconClasses:Vector.<Class> = Vector.<Class>([
			SizePreview,
			AlphaPreview
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