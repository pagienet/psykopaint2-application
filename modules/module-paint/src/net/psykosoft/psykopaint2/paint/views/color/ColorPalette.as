package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	
	public class ColorPalette extends Sprite
	{
		public var paletteSelector:Sprite;
		public var colorOverlay0:Sprite;
		public var colorOverlay1:Sprite;
		public var colorOverlay2:Sprite;
		public var colorOverlay3:Sprite;
		public var colorOverlay4:Sprite;
		public var colorOverlay5:Sprite;
		public var colorOverlay6:Sprite;
		public var colorOverlay7:Sprite;
		public var colorOverlay8:Sprite;
		public var currentColor:Sprite;
		public var autoColorSwatch:Sprite;
		public var currentColorSwatch:Sprite;
		//public var pipette:Pipette;
		/*
		public const palettes:Array = [[0x0b0b0b,0x062750,0x04396c,0x01315a,0x00353b,0x026d01,
										0x452204,0x7a1023,0xa91606,0xd94300,0xbd9c01,0xdedddb]];
		*/
		private var palettes:Vector.<Vector.<uint>>;
		private var swatches:Vector.<Sprite>;
		private var selectedPaletteIndex:int;
		private var _selectedColor:uint;
		//private var _currentIndex:int;
		private var _stage:Stage;
		private var userPaintSettings:UserPaintSettingsModel;
		private var dummyColorTransform:ColorTransform;
		
		
		
		public function ColorPalette( )
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			dummyColorTransform = new ColorTransform();
		}

		// TODO: review disposal of view
		
		private function onAddedToStage( event:Event ):void {
			_stage = stage;
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			swatches = Vector.<Sprite>([colorOverlay0,colorOverlay1,colorOverlay2,colorOverlay3,colorOverlay8,
										colorOverlay4,colorOverlay5,colorOverlay6,colorOverlay7,currentColor,
			]);
			
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				swatches[i].addEventListener(MouseEvent.CLICK, onSwatchClicked );
			}
			autoColorSwatch.addEventListener(MouseEvent.CLICK, onSwatchClicked );
			paletteSelector.mouseEnabled = false;
			currentColorSwatch.visible = false;
			currentColor.visible = false;
		}
		
		public function setUserPaintSettings( userPaintSettings:UserPaintSettingsModel ):void
		{
			this.userPaintSettings = userPaintSettings;
			this.palettes = userPaintSettings.colorPalettes;
			showPalette(0);
		
			if ( userPaintSettings.hasSourceImage )
			{
				swatches[4] = autoColorSwatch;
				colorOverlay8.visible = false;
			} else {
				swatches[4] = colorOverlay8;
				autoColorSwatch.visible = false;
				userPaintSettings.setCurrentColor(palettes[0][0]); 
				
			} 
			selectedIndex = userPaintSettings.selectedSwatchIndex;
		}
		
		private function showPalette( index:int ):void
		{
			selectedPaletteIndex = index;
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				var t:ColorTransform = swatches[i].transform.colorTransform; 
				t.color = 0xff000000 | palettes[index][i];
				swatches[i].transform.colorTransform = t;
			}
		}
		
		private function onSwatchClicked( event:Event ):void
		{
			var swatch:Sprite = event.target as Sprite;
			selectedIndex = swatches.indexOf( swatch );
		}
		
		public function set selectedIndex(index:int):void
		{
			if ( index == -1 && !userPaintSettings.pipetteIsEmpty) index = 9;
			if ( index>-1)
			{
				//userPaintSettings.selectedSwatchIndex != index &&
				if ( swatches[index] == autoColorSwatch){
					paletteSelector.x = swatches[index].x + 32;
					paletteSelector.y = swatches[index].y+37;
					_selectedColor = userPaintSettings.currentColor;
				} else if ( swatches[index] == currentColor){
					paletteSelector.x = swatches[index].x-2;
					paletteSelector.y = swatches[index].y+3;
					_selectedColor = palettes[selectedPaletteIndex][index];
				} else {
					paletteSelector.x = swatches[index].x;
					paletteSelector.y = swatches[index].y+2;
					_selectedColor = palettes[selectedPaletteIndex][index];
				}
				userPaintSettings.selectedSwatchIndex = index;
				
				userPaintSettings.setColorMode( autoColor ? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE, false );
				userPaintSettings.setCurrentColor(_selectedColor);
				
			} else {
				userPaintSettings.selectedSwatchIndex = index;
			}
			currentColor.visible = currentColorSwatch.visible = !userPaintSettings.pipetteIsEmpty;
			
		}
		
		public function get autoColor():Boolean
		{
			return (autoColorSwatch.visible && userPaintSettings.selectedSwatchIndex == 4);
		}
		
		public function set autoColor( value:Boolean ):void
		{
			if (autoColorSwatch.visible ) 
			{
				if ( value )
					selectedIndex = 4;
				else if ( userPaintSettings.selectedSwatchIndex == 4 ) selectedIndex = -1;
			}
		
		}
		
		
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		public function set selectedColor(argb:uint):void
		{
			if ( userPaintSettings.selectedSwatchIndex != -1 && !autoColor )
			{
				dummyColorTransform.color = _selectedColor = argb;
				swatches[userPaintSettings.selectedSwatchIndex].transform.colorTransform = dummyColorTransform;
				palettes[selectedPaletteIndex][userPaintSettings.selectedSwatchIndex] = argb;
			} 
		}
		
		public function changeSwatchColor(swatch:Sprite, color:uint):void
		{
			dummyColorTransform.color = color;
			swatch.transform.colorTransform = dummyColorTransform;
			palettes[selectedPaletteIndex][getSwatchIndex(swatch)] = color;
		}
		
		public function get currentPalette():Vector.<uint>
		{
			return palettes[selectedPaletteIndex];
		}
		
		public function getSwatchUnderMouse( ignoreSpecialSwatches:Boolean = false):Sprite
		{
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				if ( swatches[i].hitTestPoint(stage.mouseX,stage.mouseY,true ) )
				{
					
					return ( !(swatches[i]== autoColorSwatch || swatches[i]== currentColor )|| !ignoreSpecialSwatches ?  swatches[i] : null );
				}
			}
			return null;
		}
		
		public function getSwatchIndex( swatch:Sprite):int
		{
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				if ( swatches[i]== swatch)
				{
					return i;
				}
			}
			return -1;
		}
		
		public function selectSwatch( swatch:Sprite):void
		{
			selectedIndex = getSwatchIndex( swatch );
		}
		
		public function getSelectedSwatch():Sprite
		{
			return userPaintSettings.selectedSwatchIndex > -1 ?  swatches[userPaintSettings.selectedSwatchIndex] : null;
		}
		
		public function changeCurrentColorSwatch(color:uint):void
		{
			changeSwatchColor( currentColor, color );
		}
		
		public function get pipetteSwatchSelected():Boolean
		{
			return userPaintSettings.selectedSwatchIndex == 9 && currentColor.visible;
		}
		
		public function isAutoColorSwatch(swatch:Sprite):Boolean
		{
			return swatch == autoColorSwatch;
		}
		
		public function isPipetteSwatch(swatch:Sprite):Boolean
		{
			return swatch == currentColorSwatch;
		}
	}
}