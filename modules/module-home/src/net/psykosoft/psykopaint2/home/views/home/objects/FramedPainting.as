package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	/*
	* Contains a painting within a frame.
	* */
	public class FramedPainting extends ObjectContainer3D
	{
		private var _painting:ObjectContainer3D;
		private var _frame:ObjectContainer3D;
		private var _easel:Mesh;
		private var _view:View3D;

		public function FramedPainting( view:View3D ) {
			super();
			_view = view;
		}

		public function set easelVisible( visible:Boolean ):void {
			if( !_easel ) {

				var easelMaterial:TextureMaterial = TextureUtil.getAtfMaterial( HomeView.HOME_BUNDLE_ID, "easelImage", _view );
				easelMaterial.alphaBlending = true;
				easelMaterial.mipmap = false;

				_easel = new Mesh( new PlaneGeometry( 1024, 1024 ), easelMaterial );
				_easel.z = 10;
				_easel.y = -210;

				_easel.scale( 1.575 );
				_easel.rotationX = -90;
				addChild( _easel );
			}
			_easel.visible = visible;
		}

		override public function dispose():void {
			disposePainting();
			disposeFrame();
			super.dispose();
		}

		public function setPainting( value:ObjectContainer3D ):void {
			disposePainting();
			if ( value ) {
				_painting = value;
				addChild( _painting );
			}
		}

		public function setPaintingBmd( value:BitmapData, proxy:Stage3DProxy ):void {
			disposePainting();
			if ( value ) {
				_painting = new ObjectContainer3D();
				// TODO: not all the paintings will need transparency, frames might do tho for shadows
				_painting.addChild( TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( value, proxy, true ) );
				_painting.rotationX = -90;
				addChild( _painting );
			}
		}

		public function setFrameBmd( value:BitmapData, proxy:Stage3DProxy ):void {
			disposeFrame();
			if( value ) {
				_frame = new ObjectContainer3D();
				_frame.addChild( TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( value, proxy, true ) );
				_frame.rotationX = -90;
				addChild( _frame );
			}
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function disposePainting():void {
			if( _painting ) {
				removeChild( _painting );
				_painting = null;
			}
		}

		private function disposeFrame():void {
			if( _frame ) {
				removeChild( _frame );
			}
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get width():Number {
			return 1500;
		}

		public function get painting():ObjectContainer3D {
			return _painting;
		}

		public function get frame():ObjectContainer3D {
			return _frame;
		}
	}
}
