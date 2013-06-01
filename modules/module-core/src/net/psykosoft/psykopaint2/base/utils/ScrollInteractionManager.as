package net.psykosoft.psykopaint2.base.utils
{

	import flash.display.Stage;

	public class ScrollInteractionManager
	{
		private var _stage:Stage;
		private var _isInteracting:Boolean;
		private var _positionManager:SnapPositionManager;
		private var _positionStack:Vector.<Number>; // TODO: replace by stack util
		private var _scrollInputMultiplier:Number = 1;
		private var _throwInputMultiplier:Number = 1;

		private const STACK_COUNT:uint = 8;

		public function ScrollInteractionManager( positionManager:SnapPositionManager ) {
			_positionManager = positionManager;
			_positionStack = new Vector.<Number>();
		}

		public function set stage( value:Stage ):void {
			_stage = value;
		}

		public function startInteraction():void {
			if( _isInteracting ) return;
			_isInteracting = true;
			clearStack();
		}

		public function endInteraction():void {
			if( !_isInteracting ) return;
			_isInteracting = false;
			var delta:Number = _throwInputMultiplier * evalDelta();
			_positionManager.snap( -delta );
		}

		public function update():void {

			if( !_isInteracting || !_stage ) return;

			_positionStack.push( _stage.mouseX * _scrollInputMultiplier );
			if( _positionStack.length > STACK_COUNT ) {
				_positionStack.splice( 0, 1 );
			}

			var delta:Number = evalDelta();
			_positionManager.moveFreelyByAmount( -delta );
		}

		private function evalDelta():Number {
			if( _positionStack.length <= 1 ) return 0;
			var delta:Number = 0;
			var len:uint = _positionStack.length;
			for( var i:uint = 0; i < len; ++i ) {
				if( i > 0 ) {
					delta += _positionStack[ i ] - _positionStack[ i - 1 ];
				}
			}
			delta /= ( len - 1 );
			return delta;
		}

		private function clearStack():void {
			_positionStack = new Vector.<Number>();
		}

		public function set scrollInputMultiplier( value:Number ):void {
			_scrollInputMultiplier = value;
		}

		public function get currentX():Number {
			if( !_stage ) return 0;
			return _stage.mouseX;
		}

		public function get currentY():Number {
			if( !_stage ) return 0;
			return _stage.mouseY;
		}

		public function set throwInputMultiplier( value:Number ):void {
			_throwInputMultiplier = value;
		}
	}
}
