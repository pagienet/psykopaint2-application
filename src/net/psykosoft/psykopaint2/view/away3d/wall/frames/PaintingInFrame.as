package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.debug.Trident;

	import net.psykosoft.psykopaint2.config.Settings;

	public class PaintingInFrame extends ObjectContainer3D
	{
		private var _frame:ObjectContainer3D;

		public function PaintingInFrame( frame:ObjectContainer3D, painting:ObjectContainer3D, glass:ObjectContainer3D ) {

			super();

			// TODO: must optimize resources in frames, things can be shared, etc

//			Cc.log( this, "Frame created - glass: " + glass );

			if( Settings.DEBUG_SHOW_3D_TRIDENTS ) {
				var tri:Trident = new Trident( 250 );
				addChild( tri );
			}

			/*if( Settings.USE_INDIVIDUAL_LIGHTS_ON_FRAMES ) { // Create the frame's own light.
				var frontLight:PointLight = new PointLight();
				frontLight.ambient = 1;
				frontLight.position = new Vector3D( 0, 500, -500 );
				var lightPicker:StaticLightPicker = new StaticLightPicker( [ frontLight ] );
				addChild( frontLight );
			}
			else {
				lightPicker = sceneLightPicker;
			}*/

			painting.z = -2;
			addChild( painting );

			// Glass.
			if( glass ) {
				glass.z = -5;
				addChild( glass );
			}

			// Frame.
			_frame = frame;
			addChild( _frame );

		}

		public function get width():Number {
			return Frame( _frame ).width * _scaleX;
		}
	}
}
