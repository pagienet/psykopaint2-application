package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.Colormixer;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.FluidColorMixer;
	
	import org.osflash.signals.Signal;
	
	public class ColorPickerView extends ViewBase
	{
		public var currentColorSwatch:Sprite;
		public var colorPalette:ColorPalette;
		public var colorChangedSignal:Signal;
		public var currentColor:uint = 0;
		//private var colorMixer:Colormixer;
		private var colorMixer:FluidColorMixer;
		
		public function ColorPickerView()
		{
			super();
			colorChangedSignal = new Signal();
		}
		
		override protected function onSetup():void 
		{
			colorPalette.addEventListener( Event.CHANGE, onPaletteColorChanged );
			//colorMixer = new Colormixer( colorPalette.currentPalette );
			colorMixer = new FluidColorMixer();
			colorMixer.y = 595;
			colorMixer.x = 3;
			colorMixer.addEventListener( Event.CHANGE, onMixerColorPicked );
			colorMixer.blendMode = "multiply";
			addChildAt(colorMixer,getChildIndex(colorPalette));
		}
		
		protected function onPaletteColorChanged(event:Event):void
		{
			setCurrentColor( colorPalette.selectedColor, true );
		}
		
		protected function onMixerColorPicked( event:Event ):void {
			setCurrentColor( colorMixer.currentColor, false );
		}
		
		protected function setCurrentColor( newColor:uint, fromPalette:Boolean):void
		{
			currentColor = newColor;
			var t:ColorTransform = currentColorSwatch.transform.colorTransform;
			t.color = newColor;
			currentColorSwatch.transform.colorTransform = t;
			if (!fromPalette )  colorPalette.selectedIndex = -1;
			colorChangedSignal.dispatch();
			colorMixer.currentColor = newColor;
		}
	}
}