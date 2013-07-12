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
	public class FramedPainting extends GalleryPainting
	{
		private var _painting:Mesh;
		private var _frame:Mesh;
		private var _view:View3D;

		public function FramedPainting( view:View3D ) {
			super();
			_view = view;
			rotationX = -90;
		}

		override public function dispose():void {
			disposePainting();
			disposeFrame();
			super.dispose();
		}

		public function setPaintingBitmapData( value:BitmapData, proxy:Stage3DProxy ):void {
			disposePainting();
			if ( value ) {
				// TODO: not all the paintings will need transparency, frames might do tho for shadows
				// TODO: THIS IS A MASSIVE MEMORY LEAK BECAUSE NOTHING IS DISPOSED!!!
				_painting = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( value, proxy, true );
				addChild( _painting );
			}
		}

		public function setFrameBitmapData( value:BitmapData, proxy:Stage3DProxy ):void {
			disposeFrame();
			if( value ) {
				_frame = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( value, proxy, true );
				addChild( _frame );
			}
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function disposePainting():void {
			if( _painting ) {
				removeChild( _painting );
				_painting.dispose();
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

		override public function get painting():Mesh {
			return _painting;
		}

		public function get frame():ObjectContainer3D {
			return _frame;
		}
	}
}
