package net.psykosoft.psykopaint2.paint.commands
{

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;

	public class LoadPaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingDataModel:PaintingModel;

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
			var output:ByteArray = new ByteArray();
			var len : int = input.length/4;
			var i : int = 0;

			input.endian =  Endian.BIG_ENDIAN;
			output.endian =  Endian.LITTLE_ENDIAN;

			while(i++ < len)
				output.writeUnsignedInt(input.readUnsignedInt());

			output.length = canvasModel.textureWidth * canvasModel.textureHeight * 4;

			return output;
		}
	}
}
