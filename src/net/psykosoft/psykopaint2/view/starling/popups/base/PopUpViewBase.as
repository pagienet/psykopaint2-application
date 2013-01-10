package net.psykosoft.psykopaint2.view.starling.popups.base
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import net.psykosoft.psykopaint2.assets.starling.StarlingTextureManager;
	import net.psykosoft.psykopaint2.assets.starling.data.StarlingTextureType;
	import net.psykosoft.psykopaint2.view.starling.base.*;

	import org.osflash.signals.Signal;

	import starling.display.Button;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	public class PopUpViewBase extends StarlingViewBase
	{
		public var blockerClickedSignal:Signal;

		private var _bg:Image;
		private var _container:Sprite;
		private var _blocker:Button;

		public function PopUpViewBase() {
			super();
			blockerClickedSignal = new Signal();
		}

		override protected function onStageAvailable():void {

			_blocker = new Button( StarlingTextureManager.getTextureById( StarlingTextureType.TRANSPARENT ) );
			_blocker.addEventListener( Event.TRIGGERED, onBlockerPressed );
			addChild( _blocker );

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

			_blocker.width = stage.stageWidth;
			_blocker.height = stage.stageHeight;

			_container.x = stage.stageWidth / 2 - _bg.width / 2;
			_container.y = stage.stageHeight / 2 - _bg.height / 2;

			super.onLayout();
		}

		override public function enable():void {

			var yCache:Number = _container.y;
			_container.y -= 2000;
			TweenLite.to( _container, 1, { y: yCache, ease:Strong.easeOut } );

			super.enable();
		}
	}
}
