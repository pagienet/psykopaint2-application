package net.psykosoft.psykopaint2.app.utils
{

	import net.psykosoft.psykopaint2.app.view.home.controller.*;

	import flash.display.Stage;

	public class ScrollInteractionManager
	{
		private var _stage:Stage;
		private var _isInteracting:Boolean;
		private var _positionManager:SnapPositionManager;
		private var _positionStack:Vector.<Number>;
		private var _inputMultiplier:Number = 1;

		private const STACK_COUNT:uint = 10;

		public function ScrollInteractionManager( stage:Stage, positionManager:SnapPositionManager ) {
			_stage = stage;
			_positionManager = positionManager;
			_positionStack = new Vector.<Number>();
		}

		public function startInteraction():void {
			if( _isInteracting ) return;
			_isInteracting = true;
			clearStack();
		}

		public function endInteraction():void {
			if( !_isInteracting ) return;
			_isInteracting = false;
			var delta:Number = evalDelta();
			_positionManager.snap( -delta );
		}

		public function update():void {

			if( !_isInteracting ) return;

			_positionStack.push( _stage.mouseX * _inputMultiplier );
			if( _positionStack.length > STACK_COUNT ) {
				_positionStack.splice( 0, 1 );
			}

			var delta:Number = evalDelta();
			_positionManager.moveFreelyByAmount( -delta );
		}

		private function evalDelta():Number {
			var delta:Number = 0;
			var len:uint = _positionStack.length;
			for( var i:uint = 0; i < len; ++i ) {
				if( i > 0 ) {
					delta += _positionStack[ i ] - _positionStack[ i - 1 ];
				}
			}
			delta /= len;
			return delta;
		}

		private function clearStack():void {
			_positionStack = new Vector.<Number>();
		}

		public function set inputMultiplier( value:Number ):void {
			_inputMultiplier = value;
		}

		public function get currentX():Number {
			return _stage.mouseX;
		}

		public function get currentY():Number {
			return _stage.mouseY;
		}
	}
}
