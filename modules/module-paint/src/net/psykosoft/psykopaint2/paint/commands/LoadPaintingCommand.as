package net.psykosoft.psykopaint2.paint.commands
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.paint.model.PaintingDataModel;

	public class LoadPaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingDataModel:PaintingDataModel;

		[Inject]
		public var canvasModel:CanvasModel;

		public function LoadPaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Get painting data, translate and pass on to the drawing core.
			var data:Vector.<ByteArray> = paintingDataModel.getRgbaDataForPaintingWithId( paintingId );
			var transposedColor:ByteArray = as3ArgbToBgra( data[ 0 ] );
			var transposedHeight:ByteArray = as3ArgbToBgra( data[ 1 ] );
			var transposedSource:ByteArray = as3ArgbToBgra( data[ 2 ] );
			canvasModel.loadLayersBGRA( Vector.<ByteArray>( [ transposedColor, transposedHeight, transposedSource ] ) );
		}

		// TODO: probably very slow, find alternative
		private function as3ArgbToBgra( input:ByteArray ):ByteArray {
			input.position = 0;
			var a:int, r:int, g:int, b:int;
			var output:ByteArray = new ByteArray();
			while( input.bytesAvailable > 0 ) {
				r = input.readInt();
				g = input.readInt();
				b = input.readInt();
				a = input.readInt();
				output.writeInt( b );
				output.writeInt( g );
				output.writeInt( r );
				output.writeInt( a );
			}
			return output;
		}
	}
}
