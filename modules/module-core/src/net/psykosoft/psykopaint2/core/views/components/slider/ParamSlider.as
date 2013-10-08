package net.psykosoft.psykopaint2.core.views.components.slider
{

	import flash.display.Sprite;
	import flash.text.TextField;

	public class ParamSlider extends SliderBase
	{
		// Declared in Flash.
		public var handleView:Sprite;
		public var bgView:Sprite;
		public var valueLabel:TextField;

		public function ParamSlider() {
			super();
			setRange( 0, 220 );
			setHandle( handleView );
			setBg( bgView );
			setLabel( valueLabel );
		}
	}
}
