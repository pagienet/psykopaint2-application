package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	public class Easel extends ObjectContainer3D
	{
		private var _easelMesh:Mesh;
		private var _pictureMesh:Mesh;
		private var _frameMesh:Mesh;

		private var _view:View3D;

		public function Easel( pictureImage:BitmapData, view:View3D ) {
			super();

			_view = view;

//			var tri:Trident = new Trident( 100 );
//			tri.z -= 500;
//			addChild( tri );

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

			// Init picture mesh.
			_pictureMesh = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( bmd, _view.stage3DProxy );
			_pictureMesh.rotationX = -90;
			_pictureMesh.y = _frameMesh.y;
			_pictureMesh.z = _frameMesh.z - frameGeometry.depth / 2 - 1;
			addChild( _pictureMesh );
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
