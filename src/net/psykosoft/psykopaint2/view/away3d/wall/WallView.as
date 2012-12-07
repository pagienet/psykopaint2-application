package net.psykosoft.psykopaint2.view.away3d.wall
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.textures.BitmapCubeTexture;

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.util.Away3dAssetManager;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.view.away3d.wall.frames.PaintingInFrame;

	import org.osflash.signals.Signal;

	public class WallView extends Away3dViewBase
	{
		private var _object:ObjectContainer3D;
		private var _bitmapCubeTexture:BitmapCubeTexture;

		public var objectClickedSignal:Signal;

		public function WallView() {

			super();

			objectClickedSignal = new Signal();

			// Initialize cube texture for glass reflections.
			var bmd:BitmapData = Away3dAssetManager.getBitmapDataById( Away3dAssetManager.GallerySkyboxImage );
			_bitmapCubeTexture = new BitmapCubeTexture( bmd, bmd, bmd, bmd, bmd, bmd );

			// Tests...
			createFrame();

		}

		// TODO: must be able to choose frame type, painting, etc
		private function createFrame():void {
			Cc.info( this, "requesting frame 0 model..." );
			// Request frame model ( async ).
			Away3dAssetManager.getModelById( Away3dAssetManager.Frame0Model, onFrameModelReady );
		}
		private function onFrameModelReady( model:Mesh ):void {
			Cc.info( this, "frame 0 model: ready: " + model );
			_object = new PaintingInFrame( model.clone() as Mesh, _bitmapCubeTexture );
			_object.z = 500;
			addChild3d( _object );
		}

		override protected function onUpdate():void {

			if( _object ) {
				_object.rotationX += 0.2;
				_object.rotationY += 0.3;
				_object.rotationZ += 0.4;
			}

		}
	}
}
