package net.psykosoft.psykopaint2.app.view.popups.base
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import net.psykosoft.psykopaint2.app.managers.textures.SimpleTextureManager;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	public class PopUpViewBase extends StarlingViewBase
	{
		public var blockerClickedSignal:Signal;

		protected var _container:Sprite;
		protected var _bg:Image;
		protected var _useBlocker:Boolean = true;

		private var _animating:Boolean;
		private var _blocker:Button;

		public function PopUpViewBase() {
			super();
			blockerClickedSignal = new Signal();
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			if( _useBlocker ) {
				_blocker = new Button( SimpleTextureManager.transparentTexture );
				_blocker.addEventListener( Event.TRIGGERED, onBlockerPressed );
				_blocker.width = stage.stageWidth;
				_blocker.height = stage.stageHeight;
				addChild( _blocker );
			}

			_container = new Sprite();
			addChild( _container );

			_bg = new Image( SimpleTextureManager.solidGrayTexture );
			_bg.width = 512;
			_bg.height = 512;
			_container.addChild( _bg );

			_container.x = stage.stageWidth / 2 - _bg.width / 2;
			_container.y = stage.stageHeight / 2 - _bg.height / 2;

			// Trigger animation...
			_animating = true;
			var centerY:Number = stage.stageHeight / 2 - _bg.height / 2;
			_container.y = centerY - 2000; // TODO: redundant positioning
			TweenLite.to( _container, 1, { y: centerY, ease:Strong.easeOut, onComplete: onEnableComplete } );
		}

		override protected function onDisabled():void {

			TweenLite.killTweensOf( _container );

			if( _blocker ) {
				removeChild( _blocker );
				_blocker.removeEventListener( Event.TRIGGERED, onBlockerPressed );
				_blocker.dispose();
				_blocker = null;
			}

			if( _bg ) {
				_container.removeChild( _bg );
				_bg.dispose();
				_bg = null;
			}

			if( _container ) {
				removeChild( _container );
				_container.dispose();
				_container = null;
			}
		}

		// ---------------------------------------------------------------------
		// Animation.
		// ---------------------------------------------------------------------

		protected function finishedAnimating():void {
			// Override.
		}

		private function onEnableComplete():void {
			_animating = false;
			finishedAnimating();
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onBlockerPressed( event:Event ):void {
			blockerClickedSignal.dispatch();
		}
	}
}
