package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	
	public class BrushShapeLibrary
	{
		[Inject]
		public var stage3D : Stage3D;

		private var _shapes : Object;

		public function BrushShapeLibrary()
		{
			_shapes = {};
		}

		public function init() : void
		{
			registerDefaultShapes(stage3D.context3D);
		}
		
		public function dispose() : void
		{
			for ( var id:String in _shapes )
			{
				_shapes[id].dispose();
			}
			_shapes = {};
		}

		private function registerDefaultShapes(context3D : Context3D) : void
		{
			registerShape(new SplatBrushShape(context3D));
			registerShape(new PaintBrushShape1(context3D));
			registerShape(new LineBrushShape(context3D));
			registerShape(new PencilSketchBrushShape(context3D));
			registerShape(new WetBrushShape(context3D));
			registerShape(new BasicBrushShape(context3D));
			registerShape(new SplotchBrushShape(context3D));
			registerShape(new NoisyBrushShape(context3D));
			registerShape(new ScalesBrushShape(context3D));
			registerShape(new RenderTextureBrushShape(context3D));
			registerShape(new BasicSmoothBrushShape(context3D));
			registerShape(new SumiShape1(context3D));
			registerShape(new AlmostCircularHardShape(context3D));
			registerShape(new AlmostCircularRoughShape(context3D));
			registerShape(new DotsBrushShape(context3D));
			registerShape(new DotBrushShape(context3D));
			registerShape(new SplatterSprayShape(context3D));
			registerShape(new InkSplatsShape(context3D));
			registerShape(new SplatsShape(context3D));
			registerShape(new SprayShape(context3D));
			/*
			//disabled unused shapes
			
			registerShape(new SquareBrushShape(context3D));
			registerShape(new SquareSmoothBrushShape(context3D));
			
			registerShape(new PencilBrushShape(context3D));
			registerShape(new SplatBrushShape2(context3D));
			registerShape(new DotBrushShape(context3D));
			registerShape(new InkDotShape1(context3D));
			registerShape(new ObjectTestShape1(context3D));
			registerShape(new AntialiasedTriangleBrushShape(context3D));
			registerShape(new PrecisionTestShape(context3D));
			registerShape(new SphereBrushShape(context3D));
			
			*/
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				sendAvailableShapes();
				PsykoSocket.addMessageCallback("BrushShapeLibrary.*",this, onSocketMessage );
			}
		}

		public function registerShape(shape : AbstractBrushShape) : void
		{
			//if (_shapes[shape.id]) throw "Brush shape with id '" + shape.id + "' already registered";
			_shapes[shape.id] = shape;
		}

		public function getBrushShape(id : String) : AbstractBrushShape
		{
			if ( id == null ) return null;
			if (!_shapes[id]) throw "No brush shape with id '" + id + "' registered";
			return _shapes[id];
		}
		
		
		private function sendAvailableShapes():void
		{
			var answer:XML = <msg src="BrushShapeLibrary.sendAvailableShapes" />;
			for ( var id:String in _shapes )
			{
				answer.appendChild(<shape id={id} />);
			}
			PsykoSocket.sendString( answer.toXMLString() );
		}
		
		private function onSocketMessage( message:XML):void
		{
			var target:String = String( message.@target ).split(".")[1];
			switch ( target )
			{
				case "getAvailableShapes":
					sendAvailableShapes();
					break;
			}
		}
	}
}
