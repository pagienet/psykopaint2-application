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
		public function PaintingInFrame( frameModel:Mesh, reflectionTexture:BitmapCubeTexture ) {

			super();

			// TODO: must optimize resources in frames, things can be shared, etc

			if( Settings.DEBUG_SHOW_3D_TRIDENTS ) {
				var tri:Trident = new Trident( 250 );
				addChild( tri );
			}

			// Create the frame's own light.
			var frontLight:PointLight = new PointLight();
			frontLight.ambient = 1;
			frontLight.position = new Vector3D( 0, 500, -500 );
			var backLight:PointLight = new PointLight(); // TODO: just fooling around with this one, will most likely need to remove
			backLight.position = new Vector3D( 0, 500, 500 );
			var lightPicker:StaticLightPicker = new StaticLightPicker( [ frontLight, backLight ] );
			addChild( frontLight );

			// Create the frame's painting.
			var painting:Painting = new Painting( lightPicker );
			painting.z = -2;
			addChild( painting );

			// Identify the dimensions of the loaded painting.
			var paintingWidth:Number = painting.maxX - painting.minX;
			var paintingHeight:Number = painting.maxZ - painting.minZ;

			// Create the frame's glass.
			var glass:Glass = new Glass( lightPicker, reflectionTexture, paintingWidth, paintingHeight );
			// TODO: make sure it's working, adjust size, good reflectivity, etc
			glass.z = -5;
			addChild( glass );

			// Create the frame model.
			var frame:Frame = new Frame( frameModel, lightPicker, paintingWidth, paintingHeight );
			addChild( frame );

		}
	}
}
