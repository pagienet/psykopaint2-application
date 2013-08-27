package net.psykosoft.psykopaint2.core.views.components.previews
{
	import flash.display.MovieClip;
	
	public class AbstractPreview extends MovieClip
	{
		public function AbstractPreview()
		{
			super();
		}
		
		public function set ratio( value:Number ):void
		{
			gotoAndStop( 1 + int( 0.5 + value * totalFrames ) );
		}
	}
}