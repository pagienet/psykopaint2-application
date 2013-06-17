package net.psykosoft.psykopaint2.home.views.snapshot
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class HomeSnapShotView extends ViewBase
	{
		private var _leftSide:Bitmap;
		private var _rightSide:Bitmap;

		private const EDGE_WIDTH:Number = 122;
		private const EDGE_HEIGHT:Number = 768;

		public function HomeSnapShotView() {
			super();
			_leftSide = new Bitmap();
			addChild( _leftSide );
			_rightSide = new Bitmap();
			_rightSide.x = 1024 - EDGE_WIDTH;
			addChild( _rightSide );
		}

		override protected function onDisabled():void {
			if( _leftSide.bitmapData ) _leftSide.bitmapData.dispose();
			if( _rightSide.bitmapData ) _rightSide.bitmapData.dispose();
		}

		public function updateSnapShot( bmd:BitmapData ):void {
			trace( this, "updating snapshot, incoming bmd: " + bmd.width + "x" + bmd.height );
			var edgeBmd:BitmapData = new BitmapData( EDGE_WIDTH, EDGE_HEIGHT, false, 0 );
			var matrix:Matrix = new Matrix();
			var clip:Rectangle = new Rectangle( 0, 0, EDGE_WIDTH, EDGE_HEIGHT );
			edgeBmd.draw( bmd, matrix, null, null, clip, true );
			_leftSide.bitmapData = edgeBmd.clone();
			edgeBmd = new BitmapData( EDGE_WIDTH, EDGE_HEIGHT, false, 0 );
			matrix.translate( -( 1024 - EDGE_WIDTH ), 0 );
			edgeBmd.draw( bmd, matrix, null, null, clip, true );
			_rightSide.bitmapData = edgeBmd;
		}

		public function toggleSnapShot( show:Boolean ):void {
			_leftSide.visible = _rightSide.visible = show;
		}

		public function widen( ratio:Number ):void {
			_leftSide.x = -EDGE_WIDTH * ratio;
			_rightSide.x = 1024 - EDGE_WIDTH + EDGE_WIDTH * ratio;
		}
	}
}
