package net.psykosoft.psykopaint2.core.views.navigation
{
	import flash.display.MovieClip;
	
	import net.psykosoft.psykopaint2.base.ui.components.PsykoLabel;
	
	public class LoadingView extends MovieClip
	{
		
		public var label:PsykoLabel;
		
		public function LoadingView()
		{
			super();
			label.text = "LOADING";
			stop();
			this.gotoAndStop(int(Math.random()*this.totalFrames+1));
		}
		
		override public function set visible( value:Boolean ):void
		{
			this.gotoAndStop(int(Math.random()*this.totalFrames+1));
			super.visible = value;
		}
	}
}