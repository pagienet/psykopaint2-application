package net.psykosoft.psykopaint2.home.views.home.objects
{

	import flash.geom.Point;

	public class FrameOffsets
	{
		public static function getOffsetForFrameType( frameType:String ):Point {
			switch( frameType ) {

				case FrameType.CANVAS_FRAME: {
					return new Point( 70, 128 );
				}

				case FrameType.WHITE_FRAME: {
					return new Point( 132, 115 );
				}
			}
			throw new Error( "FrameOffsets.as - unrecognized frame." );
		}
	}
}
