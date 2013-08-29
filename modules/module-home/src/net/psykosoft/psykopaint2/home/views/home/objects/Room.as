package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.assets.HomeEmbeddedAssets;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	public class Room extends ObjectContainer3D
	{
		private var _view:View3D;
		private var _proxy:Stage3DProxy;

		private var _floor:Mesh;
		private var _floorGeometry:PlaneGeometry;
		private var _floorMaterial:TextureMaterial;
		private var _floorTexture:ATFTexture;

		private var _wall:Mesh;
		private var _wallGeometry:PlaneGeometry;
		private var _wallMaterial:TextureMaterial;
		private var _wallTexture:ATFTexture;
		private var _imageLoader:BinaryLoader; // Will load full size atf files.

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 3000;
		private const WALL_BASE_Y:Number = -500;
		private const WALL_Z:Number = 400;
		private const FLOOR_DEPTH:Number = 1750;

		override public function dispose():void {

			trace( this, "dispose()" );

			if( _imageLoader ) {
				_imageLoader.dispose();
				_imageLoader = null;
			}

			_floor.dispose();
			_floorGeometry.dispose();
			_floorMaterial.dispose();
			_floorTexture.dispose();
			_floor = null;

			_wall.dispose();
			_wallGeometry.dispose();
			_wallMaterial.dispose();
			_wallTexture.dispose();
			_wall = null;

			_view = null;
			_proxy = null;
		}

		public function Room( view:View3D, proxy:Stage3DProxy ) {
			super();
			_view = view;
			_proxy = proxy;
		}

		public function initialize():void {
			loadWall();
			loadFloor();
		}

		// -----------------------
		// Wall.
		// -----------------------

		private function loadWall():void {

			// Geometry.
			_wallGeometry = new PlaneGeometry( 1024, 1024 );
			var uvScale:Number = 0.25; // TODO: calculate exact value
			_wallGeometry.scaleUV( uvScale * WALL_WIDTH / _wallGeometry.width, 1 );

			// Mesh.
			_wall = new Mesh( _wallGeometry, null );
			_wall.scaleX = WALL_WIDTH / _wallGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / _wallGeometry.height;
			_wall.rotationX = -90;
			_wall.x = 370; // Aligns wallpaper lights with paintings.
			_wall.y = WALL_BASE_Y + WALL_HEIGHT / 2;
			_wall.z = WALL_Z;
			addChild( _wall );
		}

		// -----------------------
		// Floor.
		// -----------------------

		private function loadFloor():void {

			// Geometry.
			_floorGeometry = new PlaneGeometry( 1024, 1024 );
			_floorGeometry.scaleUV( WALL_WIDTH / _floorGeometry.width, 1 );

			// Texture.
			var cl:Class = CoreSettings.RUNNING_ON_iPAD ? HomeEmbeddedAssets.instance.FloorPaperIos : HomeEmbeddedAssets.instance.FloorPaperDesktop;
			var bytes:ByteArray = new cl() as ByteArray;
			_floorTexture = new ATFTexture( bytes );
			_floorTexture.getTextureForStage3D( _view.stage3DProxy );
			bytes.clear();

			// Material.
			_floorMaterial = new TextureMaterial( _floorTexture );
			_floorMaterial.repeat = true;
			_floorMaterial.smooth = true;
			_floorMaterial.mipmap = false;

			// Mesh.
			_floor = new Mesh( _floorGeometry, _floorMaterial );
			_floor.scaleX = WALL_WIDTH / _floorGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / _floorGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the home
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild( _floor );
		}

		// -----------------------
		// Public.
		// -----------------------

		public function changeWallpaper( url:String ):void {
			if( _imageLoader ) {
				_imageLoader.dispose();
				_imageLoader = null;
			}
			_imageLoader = new BinaryLoader();
			_imageLoader.loadAsset( url, onWallpaperImageLoaded );
		}

		private function onWallpaperImageLoaded( atf:ByteArray ):void {

			// Dispose previous?
			if( _wallMaterial ) {
				_wallMaterial.dispose();
				_wallTexture.dispose();
			}

			// Texture.
			_wallTexture = new ATFTexture( atf );

			// Material.
			_wallMaterial = new TextureMaterial( _wallTexture );
			_wallMaterial.mipmap = false;
			_wallMaterial.smooth = true;
			_wallMaterial.repeat = true;
			_wall.material = _wallMaterial;

			_imageLoader.dispose();
			_imageLoader = null;
		}

		// -----------------------
		// Getters.
		// -----------------------

		public function get wallZ():Number {
			return WALL_Z;
		}

		public function get wall():Mesh {
			return _wall;
		}
	}
}
