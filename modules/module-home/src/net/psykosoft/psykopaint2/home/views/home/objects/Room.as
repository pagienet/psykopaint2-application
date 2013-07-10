package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;

	import br.com.stimuli.loading.BulkLoader;

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	public class Room extends ObjectContainer3D
	{
		private var _wall:Mesh;
		private var _floor:Mesh;
		private var _floorMaterial:TextureMaterial;
		private var _wallMaterial:TextureMaterial;
		private var _view:View3D;
		private var _proxy:Stage3DProxy;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -500;

		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1750;

		public function Room( view:View3D, proxy:Stage3DProxy ) {
			super();
			_view = view;
			_proxy = proxy;
		}

		public function initialize():void {
			loadWall();
			loadFloor();
			loadPanels();
		}

		// -----------------------
		// Signs.
		// -----------------------

		private var _settingsPanel:Mesh;

		private function loadPanels():void {

			_settingsPanel = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage(
					BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBitmapData( "settingsPanel", true ),
					_proxy,
					true
			);
			_settingsPanel.x = 735;
			_settingsPanel.y = 805;
			_settingsPanel.rotationX = -90;
			_view.scene.addChild( _settingsPanel );

		}

		// -----------------------
		// Wall.
		// -----------------------

		private function loadWall():void {

			// Geometry.
			var wallGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			var uvScale:Number = 0.3; // TODO: calculate exact value
			wallGeometry.scaleUV( uvScale * WALL_WIDTH / wallGeometry.width, 1 );

			// Mesh.
			_wall = new Mesh( wallGeometry, null );
			changeWallpaper(
					BulkLoader.getLoader( HomeView.HOME_BUNDLE_ID ).getBinary( "defaultWallpaper", true )
			);
			_wall.scaleX = WALL_WIDTH / wallGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / wallGeometry.height;
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
			var floorGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			floorGeometry.scaleUV( WALL_WIDTH / floorGeometry.width, 1 );

			// Texture.
			var floorTexture:ATFTexture = TextureUtil.getAtfTexture( HomeView.HOME_BUNDLE_ID, "floorWood", _view );

			// Material.
			_floorMaterial = new TextureMaterial( floorTexture );
			_floorMaterial.repeat = true;
			_floorMaterial.smooth = true;
			_floorMaterial.mipmap = false;

			// Mesh.
			_floor = new Mesh( floorGeometry, _floorMaterial );
			_floor.scaleX = WALL_WIDTH / floorGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / floorGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the home
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild( _floor );
		}

		// -----------------------
		// Overrides.
		// -----------------------

		override public function dispose():void {

			trace( this, "dispose()" );

//			_floorMaterial.texture.dispose();
//			_floorMaterial.dispose();
			_floor.dispose();
			_floor = null;

//			_wallTexture.dispose();
//			_wallMaterial.dispose();
			_wall.dispose();
			_wall = null;
		}

		// -----------------------
		// Public.
		// -----------------------

		public function changeWallpaper( atf:ByteArray ):void {

			// TODO: make sure previous atf is disposed

			// Material.
			_wallMaterial = new TextureMaterial( new ATFTexture( atf ) );
			_wallMaterial.mipmap = false;
			_wallMaterial.smooth = true;
			_wallMaterial.repeat = true;
			_wall.material = _wallMaterial;
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

		public function get settingsPanel():Mesh {
			return _settingsPanel;
		}
	}
}
