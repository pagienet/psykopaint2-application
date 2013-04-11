package net.psykosoft.psykopaint2.app.view.components.sliders
{
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class HSlider extends Sprite
	{
		private var _bgView:Image;
		private var _handleView:Image;
		
		public function HSlider()
		{
			super();
			
			
			_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("sliderBg"));
			this.addChild(_bgView); 
			
			_handleView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("sliderHandle"));
			this.addChild(_handleView); 
			_handleView.x = 150;
			
		}
		
		
		
	}
}