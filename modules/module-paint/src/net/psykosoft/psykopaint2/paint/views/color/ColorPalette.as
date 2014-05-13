package net.psykosoft.psykopaint2.paint.views.color
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
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
		public var eraser:Sprite;
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
		private var triggerSourcePreviewTimeoutID:int;
		
		private var desaturate:ColorMatrixFilter = new ColorMatrixFilter([0.333,0.3333,0.3333,0,0,0.333,0.3333,0.3333,0,0,0.333,0.3333,0.3333,0,0,0,0,0,1,0]);
		
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
			
			swatches = Vector.<Sprite>([colorOverlay0,colorOverlay1,colorOverlay2,colorOverlay3,colorOverlay7,
										eraser,colorOverlay4,colorOverlay5,colorOverlay6,currentColor,
			]);
			
			for ( var i:int = 0; i < swatches.length; i++ )
			{
				swatches[i].addEventListener(MouseEvent.CLICK, onSwatchClicked );
			}
			autoColorSwatch.addEventListener(MouseEvent.CLICK, onSwatchClicked );
			autoColorSwatch.addEventListener(MouseEvent.MOUSE_DOWN, onAutoColorPressed );
			paletteSelector.mouseEnabled = false;
			currentColorSwatch.visible = false;
			currentColor.visible = false;
		}
		
		protected function onAutoColorPressed(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onAutoColorReleased );
			clearTimeout( triggerSourcePreviewTimeoutID )
			triggerSourcePreviewTimeoutID = setTimeout( triggerSourcePreview , 100 );
		}
		
		protected function onAutoColorReleased(event:MouseEvent):void
		{
			clearTimeout( triggerSourcePreviewTimeoutID )
			stage.removeEventListener(MouseEvent.MOUSE_UP, onAutoColorReleased );
			if ( triggerSourcePreviewTimeoutID == -1 ) dispatchEvent( new Event("Hide Source") );
		}
		
		protected function triggerSourcePreview():void
		{
			dispatchEvent( new Event("Show Source") );
			triggerSourcePreviewTimeoutID = -1;
		}
		
		public function setUserPaintSettings( userPaintSettings:UserPaintSettingsModel ):void
		{
			this.userPaintSettings = userPaintSettings;
			this.palettes = userPaintSettings.colorPalettes;
			showPalette(0);
		
			if ( userPaintSettings.hasSourceImage )
			{
				swatches[4] = autoColorSwatch;
				colorOverlay7.visible = false;
			} else {
				swatches[4] = colorOverlay7;
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
				if ( i != 5 )
				{
					var t:ColorTransform = swatches[i].transform.colorTransform; 
					t.color = 0xff000000 | palettes[index][i];
					swatches[i].transform.colorTransform = t;
				} else {
					swatches[i].filters = [desaturate];
				}
			}
		}
		
		private function onSwatchClicked( event:Event ):void
		{
			var swatch:Sprite = event.target as Sprite;
			selectedIndex = swatches.indexOf( swatch );
			
		}
		
		public function get selectedIndex():int
		{
			return userPaintSettings.selectedSwatchIndex;
		}
		
		public function set selectedIndex(index:int):void
		{
			if ( index == -1 && !userPaintSettings.pipetteIsEmpty) index = 9;
			if ( index>-1)
			{
				var sendColorSignal:Boolean = false;
				var newColorMode:int = PaintMode.COLOR_MODE;
				//userPaintSettings.selectedSwatchIndex != index &&
				if ( swatches[index] == autoColorSwatch){
					//paletteSelector.x = swatches[index].x + 32;
					//paletteSelector.y = swatches[index].y+37;
					TweenLite.to(paletteSelector,0.2,{ease:Expo.easeOut,x:swatches[index].x + 32,y:swatches[index].y+37});
					_selectedColor = userPaintSettings.currentColor;
					newColorMode = PaintMode.PHOTO_MODE;
				} else if ( swatches[index] == eraser){
					//paletteSelector.x = swatches[index].x + 32;
					//paletteSelector.y = swatches[index].y+37;
					TweenLite.to(paletteSelector,0.2,{ease:Expo.easeOut,x:swatches[index].x + 32,y:swatches[index].y+37});
					_selectedColor = 0;
					newColorMode = PaintMode.ERASER_MODE;
				} else if ( swatches[index] == currentColor){
					//paletteSelector.x = swatches[index].x-2;
					//paletteSelector.y = swatches[index].y+3;
					TweenLite.to(paletteSelector,0.2,{ease:Expo.easeOut,x:swatches[index].x -2,y:swatches[index].y+3});
					_selectedColor = palettes[selectedPaletteIndex][index];
					sendColorSignal = true;
				} else {
					//paletteSelector.x = swatches[index].x;
					//paletteSelector.y = swatches[index].y+2;
					TweenLite.to(paletteSelector,0.2,{ease:Expo.easeOut,x:swatches[index].x,y:swatches[index].y+2});

					_selectedColor = palettes[selectedPaletteIndex][index];
					sendColorSignal = true;
				}
				
				if ( userPaintSettings.colorMode != PaintMode.COSMETIC_MODE )
				{
					userPaintSettings.selectedSwatchIndex = index;
					userPaintSettings.setCurrentColor(_selectedColor, sendColorSignal);
					userPaintSettings.setColorMode(newColorMode);// autoColor ? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE );
					
					userPaintSettings.eraserMode = (index == 5);
				}
				eraser.filters = index == 5 ? [] : [desaturate];
				
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
			if ( userPaintSettings.selectedSwatchIndex != -1 && !autoColor && userPaintSettings.selectedSwatchIndex != 5)
			{
				dummyColorTransform.color = _selectedColor = argb;
				swatches[userPaintSettings.selectedSwatchIndex].transform.colorTransform = dummyColorTransform;
				palettes[selectedPaletteIndex][userPaintSettings.selectedSwatchIndex] = argb;
			} 
		}
		
		public function changeSwatchColor(swatch:Sprite, color:uint):void
		{
			if ( swatch != eraser )
			{
				dummyColorTransform.color = color;
				swatch.transform.colorTransform = dummyColorTransform;
				palettes[selectedPaletteIndex][getSwatchIndex(swatch)] = color;
			}
			if (swatch == currentColor)
			{
				if ( selectedIndex != 9 ) selectedIndex = 9;
				if ( !currentColorSwatch.visible)
				{
					currentColorSwatch.visible = true;
					currentColor.visible = true;
				}
			}
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