package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;

	import net.psykosoft.psykopaint2.core.views.popups.base.*;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	import org.osflash.signals.Signal;

	public class PopUpManagerView extends ViewBase
	{
		private var _popUp:PopUpViewBase;
		protected var _blocker:Sprite;

		public var popUpHiddenSignal:Signal;
		public var popUpShownSignal:Signal;

		public function PopUpManagerView() {
			super();

			popUpHiddenSignal = new Signal();
			popUpShownSignal = new Signal();

			_blocker = new Sprite();
			_blocker.visible = false;
			_blocker.graphics.beginFill( 0x000000, 0.25 );
			_blocker.graphics.drawRect( 0, 0, 1024, 768 );
			_blocker.graphics.endFill();
			_blocker.addEventListener( MouseEvent.CLICK, onBlockerClicked );
			addChildAt( _blocker, 0 );

			addEventListener(MouseEvent.CLICK, killEvent);
			addEventListener(MouseEvent.MOUSE_DOWN, killEvent);
			addEventListener(MouseEvent.MOUSE_MOVE, killEvent);
			addEventListener(MouseEvent.MOUSE_UP, killEvent);
			addEventListener(TouchEvent.TOUCH_TAP, killEvent);
			addEventListener(TouchEvent.TOUCH_BEGIN, killEvent);
			addEventListener(TouchEvent.TOUCH_END, killEvent);
			addEventListener(TouchEvent.TOUCH_MOVE, killEvent);

			enable();
		}

		private function killEvent(event:Event):void
		{
			event.stopImmediatePropagation();
		}

		public function set data(data:Array):void {
			if(_popUp) {
				_popUp.data = data;
			}
		}

		// -----------------------
		// Show.
		// -----------------------

		public function showPopUpOfClass( popUpClass:Class ):void {

			trace( this, "showing pop up of class: " + popUpClass );

			if( _popUp ) {
				onHidePopUpComplete();
			}

			_popUp = new popUpClass();
			addChild( _popUp );
			_popUp.enable();
			_blocker.visible = true;
			showPopUpAnimated( _popUp );
		}

		private function showPopUpAnimated( popUp:PopUpViewBase ):void {
			_popUp.onGoingToAnimateIn();
			TweenLite.killTweensOf( popUp );
			popUp.x = 1024;
			//Don't ANYMATE POPUP. 1 BECAUSE IT'S SLOW. 2 BECAUSE PEOPLE CAN'T WAIT
			TweenLite.to( popUp, 0.0, { x: 0, delay: 0.0, ease: Strong.easeOut, onComplete: onShowPopUpComplete } );
		}

		private function onShowPopUpComplete():void {
			popUpShownSignal.dispatch();
			_popUp.onAnimatedIn();
		}

		// -----------------------
		// Hide.
		// -----------------------

		public function hideLastPopUp():void {
			if( !_popUp ) return;
			_blocker.visible = false;
			hidePopUpAnimated( _popUp );
		}

		private function hidePopUpAnimated( popUp:PopUpViewBase ):void {
			_popUp.onGoingToAnimateOut();
			TweenLite.killTweensOf( popUp );
			popUp.x = 0;
			TweenLite.to( popUp, 0.5, { x: 1024, delay: 0.0, ease: Strong.easeIn, onComplete: onHidePopUpComplete } );
		}

		private function onHidePopUpComplete():void {
			_popUp.onAnimatedOut();
			_popUp.disable();
			removeChild( _popUp );
			_popUp = null;
			popUpHiddenSignal.dispatch();
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onBlockerClicked( event:MouseEvent ):void {
			_popUp.onBlockerClicked();
		}
	}
}
