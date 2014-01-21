package net.psykosoft.psykopaint2.core.views.components.button
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.PanGestureDirection;

	public class BitmapButton extends NavigationButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;
		public var pin:MovieClip;

		private var _pin:MovieClip;
		private var _pinDefaultY:Number;
		private var _panGestureVertical:PanGesture;
		
		public function BitmapButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			setPin();
			label.visible = false;
		}

		private function setPin():void {
			_pin = pin;
			_pin.stop();
			_pinDefaultY = _pin.y;
			randomizePinsAndRotation();
		}

		private function randomizePinsAndRotation():void {
			_icon.rotation = 4 * Math.random() - 2;
		}

		override protected function adjustBitmap():void {
			// TODO: might want to maintain aspect ratio and mask
			_iconBitmap.width = 256 * 0.5;
			_iconBitmap.height = 192 * 0.5;
			super.adjustBitmap();
		}

		override protected function updateSelected():void {
			var frame:uint = _selected + 1;
			_pin.gotoAndStop( frame );
		}
		
		override protected function onAddedToStage( event:Event ):void
		{
			super.onAddedToStage( event );
			initOneFingerVerticalPan();
		}
		
		public function enterDeleteMode():void
		{
			TweenLite.to( _pin, 0.2, { y: _pinDefaultY - 30, ease: Strong.easeInOut } );
		}
		
		public function enterDefaultMode():void
		{
			TweenLite.to( _pin, 0.2, { y: _pinDefaultY, ease: Strong.easeInOut } );
		}
		
		private function initOneFingerVerticalPan():void {
			if ( !_panGestureVertical )
			{
				_panGestureVertical = new PanGesture( this );
				_panGestureVertical.minNumTouchesRequired = _panGestureVertical.maxNumTouchesRequired = 1;
				_panGestureVertical.direction = PanGestureDirection.VERTICAL;
				_panGestureVertical.addEventListener( GestureEvent.GESTURE_BEGAN, onVerticalPanGestureBegan );
				_panGestureVertical.addEventListener( GestureEvent.GESTURE_ENDED, onVerticalPanGestureEnded );
			}
		
		}
		
		private function onVerticalPanGestureBegan( event:GestureEvent ):void {
			trace("vertical pan started");
			enterDeleteMode();
		}
		
		private function onVerticalPanGestureEnded( event:GestureEvent ):void {
			trace("vertical pan ended"); 
			
		}
	}
}
