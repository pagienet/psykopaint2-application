package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	import org.osflash.signals.Signal;

	public class Easel extends ObjectContainer3D
	{
		private var _easelMesh:Mesh;
		private var _pictureMesh:Mesh;
		private var _frameMesh:Mesh;

		private var _view:View3D;

		public var clickedSignal:Signal;

		public function Easel( pictureImage:BitmapData, view:View3D ) {
			super();

			clickedSignal = new Signal();

			_view = view;

			// Init easel mesh.
			var easelMaterial:TextureMaterial = TextureUtil.getAtfMaterial( HomeView.HOME_BUNDLE_ID, "easelImage", view );
			easelMaterial.alphaBlending = true;
			easelMaterial.mipmap = false;
			_easelMesh = new Mesh( new PlaneGeometry( 1024, 1024 ), easelMaterial );
			_easelMesh.scale( 1.575 );
			_easelMesh.rotationX = -90;
			addChild( _easelMesh );

			updateImage( pictureImage );
		}

		public function get width():Number {
			return 1024;
		}

		public function updateImage( bmd:BitmapData ):void {

			// Dispose.
			if( _frameMesh ) {
				removeChild( _frameMesh );
				_frameMesh.dispose();
				_frameMesh = null;
			}
			if( _pictureMesh ) {
				removeChild( _pictureMesh );
				_pictureMesh.dispose();
				_pictureMesh = null;
			}

			// Init frame mesh.
			var frameGeometry:CubeGeometry = new CubeGeometry( bmd.width, bmd.height, 25 ); // TODO: must adapt to the size of the canvas
			var frameMaterial:ColorMaterial = new ColorMaterial( 0x333333, 1 );
			_frameMesh = new Mesh( frameGeometry, frameMaterial );
			_frameMesh.y = 768 / 2 - 170; // TODO: must adapt to the size of the canvas
			_frameMesh.z = -25;
			addChild( _frameMesh );

			// Uncomment to visualize painting center.
			/*var tri:Trident = new Trident( 100 );
			tri.z -= 30;
			_frameMesh.addChild( tri );*/

			// Init picture mesh.
			_pictureMesh = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( bmd, _view.stage3DProxy );
			_pictureMesh.name = "EaselPicture";
			_pictureMesh.rotationX = -90;
			_pictureMesh.y = _frameMesh.y;
			_pictureMesh.z = _frameMesh.z - frameGeometry.depth / 2 - 1;
			_pictureMesh.mouseEnabled = true;
			_pictureMesh.addEventListener( MouseEvent3D.MOUSE_DOWN, onPictureMouseDown );
			addChild( _pictureMesh );
		}

		private function onPictureMouseDown( event:MouseEvent3D ):void {
			clickedSignal.dispatch();
		}

		override public function dispose():void {

			/*var material:TextureMaterial = _easelMesh.material as TextureMaterial;
			var texture:BitmapTexture = material.texture as BitmapTexture;
			texture.dispose();
			material.dispose();*/
			removeChild( _easelMesh );
			_easelMesh.dispose();
			_easelMesh = null;

			_view = null;

			super.dispose();
		}
	}
}
