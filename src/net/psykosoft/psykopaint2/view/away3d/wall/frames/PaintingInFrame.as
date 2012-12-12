package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.textures.BitmapCubeTexture;

	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.config.Settings;

	public class PaintingInFrame extends ObjectContainer3D
	{
		private var _width:Number;

		private var _height:Number;

		public function PaintingInFrame( frameModel:Mesh, reflectionTexture:BitmapCubeTexture, sceneLightPicker:StaticLightPicker ) {

			super();

			// TODO: must optimize resources in frames, things can be shared, etc

			if( Settings.DEBUG_SHOW_3D_TRIDENTS ) {
				var tri:Trident = new Trident( 250 );
				addChild( tri );
			}

			if( Settings.USE_INDIVIDUAL_LIGHTS_ON_FRAMES ) { // Create the frame's own light.
				var frontLight:PointLight = new PointLight();
				frontLight.ambient = 1;
				frontLight.position = new Vector3D( 0, 500, -500 );
				var lightPicker:StaticLightPicker = new StaticLightPicker( [ frontLight ] );
				addChild( frontLight );
			}
			else {
				lightPicker = sceneLightPicker;
			}

			// Create the frame's painting.
			var painting:Painting = new Painting( lightPicker );
			painting.z = -2;
			addChild( painting );

			// Identify the dimensions of the loaded painting.
			_width = painting.maxX - painting.minX;
			_height = painting.maxZ - painting.minZ;

			// Create the frame's glass.
			if( Settings.USE_REFLECTIONS_ON_FRAMES ) {
				var glass:Glass = new Glass( lightPicker, reflectionTexture, _width, _height );
				// TODO: make sure it's working, adjust size, good reflectivity, etc
				glass.z = -5;
				addChild( glass );
			}

			// Create the frame model.
			var frame:Frame = new Frame( frameModel, lightPicker, _width, _height );
			addChild( frame );

		}

		public function get width():Number {
			return _width;
		}

		public function get height():Number {
			return _height;
		}
	}
}
