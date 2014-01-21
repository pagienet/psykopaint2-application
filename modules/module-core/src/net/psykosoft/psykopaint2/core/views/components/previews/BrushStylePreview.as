package net.psykosoft.psykopaint2.core.views.components.previews
{
	import flash.display.MovieClip;

	public class BrushStylePreview extends MovieClip
	{
		private static var styleToFrame:Array = [
			"paint1","basic","splat","line","sumi",
			"Small","Medium","Large",
			"splotch","basic smooth","noisy"];
		
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