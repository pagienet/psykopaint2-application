package net.psykosoft.psykopaint2.core.views.components.slider
{

	import flash.display.Sprite;
	import flash.text.TextField;

	public class AlphaSlider extends SliderBase
	{
		// Declared in Flash.
		public var handleView:Sprite;
		public var bgView:Sprite;
		public var valueLabel:TextField;

		public function AlphaSlider() {
			super();
			setRange( 72.6, 540.1 );
			setHandle( handleView );
			setBg( bgView );
			setLabel( valueLabel );
			valueLabel.visible = false;
		}
	}
}
