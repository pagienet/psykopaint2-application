package net.psykosoft.psykopaint2.view.away3d.wall.wallframes
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.primitives.PlaneGeometry;

	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.Frame;

	public class WallFrame extends ObjectContainer3D
	{
		private var _frame:Frame;

		public function WallFrame( frame:Frame, painting:Picture, shadow:Mesh, shadowDistance:Number ) {

			super();

//			Cc.log( this, "Frame created - glass: " + glass );

//			var tri:Trident = new Trident( 250 );
//			addChild( tri );

			// Frame.
			_frame = frame;
			_frame.fitToPainting( painting.width, painting.height );
			addChild( _frame );

			// Painting.
			painting.z = -_frame.depth / 2 - 1;
			addChild( painting );

			// Shadow.
			shadow.scaleX = 1.20 * _frame.width / PlaneGeometry( shadow.geometry ).width;
			shadow.scaleZ = 1.25 * _frame.height / PlaneGeometry( shadow.geometry ).height;
			shadow.z = _frame.depth / 2 + shadowDistance - 10;
			shadow.y = -65;
			addChild( shadow );

		}

		public function get width():Number {
			return _frame.width * _scaleX;
		}

		public function get depth():Number {
			return _frame.depth * _scaleX;
		}
	}
}
