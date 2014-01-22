package net.psykosoft.psykopaint2.core.views.components.previews
{
	import flash.display.MovieClip;

	public class BrushStylePreview extends MovieClip
	{
		private static var styleToFrame:Array = [
			"paint1","basic","splat","line","sumi",
			"Small","Medium","Large",
			"splotch","basic smooth","noisy",
			"eraser1","eraser2","eraser3","eraser4",
			"No Style","Contrast Style","Black and White Style","Mona Lisa Style","William Turner Style","Miro Style","Picasso Style","Supersaturated Style"
		];
		
		public function BrushStylePreview()
		{
			super();
		}
		
		public function showIcon( id:String ):void
		{
			var idx:int = styleToFrame.indexOf(id);
			if ( idx!=-1)
				gotoAndStop(idx+1);
			else
				throw("no icon for style '"+id+"'");
		}
	}
}