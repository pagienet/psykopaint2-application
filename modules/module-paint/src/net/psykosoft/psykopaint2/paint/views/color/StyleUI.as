package net.psykosoft.psykopaint2.paint.views.color
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.views.components.previews.BrushStylePreview;
	
	public class StyleUI extends Sprite
	{
		public var slider1Handle:MovieClip;
		public var slider2Handle:MovieClip;
		public var slider1Bar:Sprite;
		public var slider2Bar:Sprite;
		public var styleBar:Sprite;
		public var styleSelector:Sprite;
		
		private var styleIconHolder:Sprite;
		private var sliderPaddingLeft:Number = 40;
		private var sliderRange:Number = 277 - sliderPaddingLeft;
		private var sliderOffset:int = 42;
		private var previewIcon:BrushStylePreview;
		private var previewDelay:int;
		private var activeSliderIndex:int;
		
		private var uiParameters:Vector.<PsykoParameter>;
		private var styleParameter:PsykoParameter;
		private var previewIcons:Object;
		
		private var sliderSnap:Vector.<Vector.<Number>>;
		private var sliderSnapDistance:Number = 0.05;
		private var _showFirstTimeStyleSliderAnimation:Boolean = true;
		
		public function StyleUI()
		{
			super();
		}
		
		public function setup(slider1Icon:int, slider2Icon:int):void
		{
			slider1Handle.mouseEnabled = false;
			slider1Handle.gotoAndStop(slider1Icon);
			slider2Handle.mouseEnabled = false;
			slider2Handle.gotoAndStop(slider2Icon);
			
			styleSelector.mouseEnabled = false;
			
			styleIconHolder = new Sprite();
			styleIconHolder.x = styleBar.x + 40;
			styleIconHolder.y = styleBar.y + 36;
			styleIconHolder.mouseEnabled = false;
			styleIconHolder.mouseChildren = false;
			
			previewIcon = new BrushStylePreview();
			previewIcon.y = -45;
			previewIcon.height = 128;
			previewIcon.scaleX = previewIcon.scaleY;
			addChildAt(styleIconHolder,getChildIndex(styleBar)+1);
			
			sliderSnap = new Vector.<Vector.<Number>>(2,true);
			
			initUI();
		}
		
		public function onEnabled():void
		{
			styleBar.addEventListener(MouseEvent.MOUSE_DOWN, onStyleMouseDown );
			slider1Bar.addEventListener(MouseEvent.MOUSE_DOWN, onSlider1MouseDown );
			slider2Bar.addEventListener(MouseEvent.MOUSE_DOWN, onSlider2MouseDown );
		}
		
		public function onDisabled():void
		{
			styleBar.removeEventListener(MouseEvent.MOUSE_DOWN, onStyleMouseDown );
			slider1Bar.removeEventListener(MouseEvent.MOUSE_DOWN, onSlider1MouseDown );
			slider2Bar.removeEventListener(MouseEvent.MOUSE_DOWN, onSlider2MouseDown );
			if ( stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStyleMouseMove );
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStyleMouseUp );
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
				stage.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			}
		}
		
		public function showStyleUI( showSelector:Boolean, showSlider1:Boolean, showSlider2:Boolean):void
		{
			styleBar.visible =  styleSelector.visible = styleIconHolder.visible = showSelector;
			slider1Bar.visible = slider1Handle.visible = showSlider1;
			slider2Bar.visible = slider2Handle.visible = showSlider2;
		}
		
		protected function onStyleMouseDown( event:MouseEvent ):void
		{
			if ( styleBar.mouseX < sliderPaddingLeft - 27 || styleBar.mouseX > sliderPaddingLeft + sliderRange + 32 || styleBar.mouseY < 0 || styleBar.mouseY > 60) return;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStyleMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onStyleMouseUp );
			
			//previewDelay = setTimeout(showStylePreview,200);
			//MATHIEU NO DELAY ANYMORE
			showStylePreview();
			onStyleMouseMove();
		}
		
		private function showStylePreview():void
		{
			styleBar.addChild(previewIcon);
			TweenLite.killTweensOf(previewIcon);
			previewIcon.alpha=0;
			TweenLite.to(previewIcon,0.1,{overwrite:false,ease:Expo.easeOut,alpha:1});
		}
		
		protected function onStyleMouseMove( event:MouseEvent = null ):void
		{
			
			var sx:Number = (styleBar.mouseX - sliderPaddingLeft) / sliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			previewIcon.x = sx * sliderRange + sliderPaddingLeft;
			
			if ( styleParameter )
			{
				var index:int = sx * (styleParameter.stringList.length - 1) + 0.5;
				
				var spacing:Number = sliderRange / (styleParameter.stringList.length - 1);
				//styleSelector.x = sliderOffset + styleBar.x + index * spacing;
				TweenLite.to(styleSelector,0.2,{overwrite:false,ease:Expo.easeOut,x:sliderOffset + styleBar.x + index * spacing});
				styleParameter.index = index;
				
				updateStyleSliderShuffling();
				
				if ( index!= 0 && _showFirstTimeStyleSliderAnimation && uiParameters[0].numberValue == 0 )
				{
					_showFirstTimeStyleSliderAnimation = false;
					TweenLite.to(slider1Handle,0.25,{ease:Quad.easeInOut,x:sliderOffset + slider1Bar.x  + 0.5 * sliderRange,
						onComplete:function():void{
							uiParameters[0].numberValue = 0.5;
						}});
				}
				
				//styleIconHolder.setChildIndex( previewIcons[index], styleIconHolder.numChildren-1);
				previewIcon.showIcon( styleParameter.stringValue );
			}
		}
		
		private function updateStyleSliderShuffling():void
		{
			var index:int = styleParameter.index;
			var currentIndex:int = styleIconHolder.numChildren-1;
			var maxIndex:int = currentIndex;
			styleIconHolder.setChildIndex( previewIcons[index], currentIndex);
			var maxLoop:int = Math.max(maxIndex-index,index);
			for ( var i:int = 1; i < maxLoop; i++ )
			{
				
				if ( index + i <=maxIndex )
				{
					currentIndex--;
					styleIconHolder.setChildIndex( previewIcons[index + i],currentIndex);
				}
				if ( index - i > -1 )
				{
					currentIndex--;
					styleIconHolder.setChildIndex( previewIcons[index - i],currentIndex);
				}
			}
		}
		
		protected function onStyleMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStyleMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStyleMouseUp );
			//if ( styleBar.contains(previewIcon)) styleBar.removeChild(previewIcon);
			
			TweenLite.to(previewIcon,0.3,{overwrite:false,delay:0.4,ease:Expo.easeOut,alpha:0,onComplete:function():void{
				if ( styleBar.contains(previewIcon)) styleBar.removeChild(previewIcon);
			}});
			//clearTimeout(previewDelay);
		}
		
		protected function onSlider1MouseDown( event:MouseEvent ):void
		{
			if ( slider1Bar.mouseX < sliderPaddingLeft - 27 || slider1Bar.mouseX > sliderPaddingLeft + sliderRange + 32 || slider1Bar.mouseY < 5 || slider1Bar.mouseY > 60) return;
			activeSliderIndex = 0;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			onSliderMouseMove();
		}
		
		protected function onSlider2MouseDown( event:MouseEvent ):void
		{
			if ( slider2Bar.mouseX < sliderPaddingLeft - 27 || slider2Bar.mouseX > sliderPaddingLeft + sliderRange + 32 || slider2Bar.mouseY < 5 || slider2Bar.mouseY > 60) return;
			activeSliderIndex = 1;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			onSliderMouseMove();
		}
		
		protected function onSliderMouseMove( event:MouseEvent = null ):void
		{
			var sx:Number = (slider1Bar.mouseX - sliderPaddingLeft) / sliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			if ( sliderSnap[activeSliderIndex] != null )
			{
				for ( var i:int = 0; i < sliderSnap[activeSliderIndex].length; i++ )
				{
					if ( Math.abs(sliderSnap[activeSliderIndex][i]-sx) <= sliderSnapDistance )
					{
						sx = sliderSnap[activeSliderIndex][i];
						break;
					}
				}
				
			}
			
			switch ( activeSliderIndex )
			{
				case 0: 
					slider1Handle.x = sliderOffset + slider1Bar.x  +  + sx * sliderRange;
					break;
				case 1: 
					slider2Handle.x = sliderOffset + slider2Bar.x  + sx * sliderRange;
					break;
			}
			if ( uiParameters ) uiParameters[activeSliderIndex].normalizedValue = sx;
		}
		
		protected function onSliderMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
		}
		
		public function setParameters( styleParameter:PsykoParameter, slider1Parameter:PsykoParameter, slider2Parameter:PsykoParameter ):void 
		{
			uiParameters = new Vector.<PsykoParameter>();
			uiParameters[0] = slider1Parameter;
			uiParameters[1] = slider2Parameter;
				
			this.styleParameter = styleParameter;
			//showStyleIcons(styleParameter);
			this.styleParameter.addEventListener(Event.CHANGE,onStyleListChanged );
		}
		
		
		
		public function setSnappings( slider1:Vector.<Number> = null, slider2:Vector.<Number> = null ):void
		{
			sliderSnap[0] = slider1;
			sliderSnap[1] = slider2;
			
		}
		
		private function initUI():void
		{
			slider1Handle.x = sliderOffset + slider1Bar.x  + uiParameters[0].normalizedValue * sliderRange;
			slider2Handle.x = sliderOffset + slider2Bar.x  + uiParameters[1].normalizedValue * sliderRange;
			
			
			while( styleIconHolder.numChildren > 0 ) styleIconHolder.removeChildAt(0);
			var styleIds:Vector.<String> = styleParameter.stringList;
			previewIcons = new Vector.<BrushStylePreview>();
			for (var i:int = 0; i< styleIds.length; i++ )
			{
				var preview:BrushStylePreview = new BrushStylePreview();
				preview.showIcon(styleIds[i]);
				preview.height = 48;
				preview.scaleX = preview.scaleY;
				preview.x = (sliderRange / (styleIds.length - 1)) * i ;
				styleIconHolder.addChildAt( preview,0 );
				previewIcons.push( preview );
			}
			
			var spacing:Number = sliderRange / (styleParameter.stringList.length - 1);
			styleSelector.x = sliderOffset + styleBar.x + styleParameter.index * spacing;
			updateStyleSliderShuffling();
		}
		
		protected function onStyleListChanged(event:Event):void
		{
			if ( styleParameter.stringList.length > previewIcons.length )
			{
				initUI();
			}
		}
	}
}