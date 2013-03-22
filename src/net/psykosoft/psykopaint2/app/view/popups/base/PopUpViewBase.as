package net.psykosoft.psykopaint2.app.view.popups.base
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import net.psykosoft.psykopaint2.app.assets.starling.StarlingTextureManager;
	import net.psykosoft.psykopaint2.app.assets.starling.data.StarlingTextureType;
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

		override protected function onStageAvailable():void {

			if( _useBlocker ) {
				_blocker = new Button( StarlingTextureManager.getTextureById( StarlingTextureType.TRANSPARENT ) );
				_blocker.addEventListener( Event.TRIGGERED, onBlockerPressed );
				addChild( _blocker );
			}

			_container = new Sprite();
			addChild( _container );

			_bg = new Image( StarlingTextureManager.getTextureById( StarlingTextureType.SOLID_GRAY ) );
			_bg.width = 512;
			_bg.height = 512;
			_container.addChild( _bg );

			super.onStageAvailable();
		}

		private function onBlockerPressed( event:Event ):void {
			blockerClickedSignal.dispatch();
		}

		override protected function onLayout():void {

			if( _useBlocker ) {
				_blocker.width = stage.stageWidth;
				_blocker.height = stage.stageHeight;
			}

			_container.x = stage.stageWidth / 2 - _bg.width / 2;
			if( !_animating ) {
				_container.y = stage.stageHeight / 2 - _bg.height / 2;
			}

			super.onLayout();
		}

		override public function enable():void {

			_animating = true;

			var centerY:Number = stage.stageHeight / 2 - _bg.height / 2;
			_container.y = centerY - 2000;
			TweenLite.to( _container, 1, { y: centerY, ease:Strong.easeOut, onComplete: onEnableComplete } );

			super.enable();
		}

		protected function finishedAnimating():void {
			// Override.
		}

		private function onEnableComplete():void {
			_animating = false;
			finishedAnimating();
		}
	}
}
