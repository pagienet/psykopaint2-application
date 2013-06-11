package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.DelaunayBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.PencilBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.RibbonBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.ShatterBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.UncoloredSprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterDamageBrush;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.resources.ITextureManager;
	
	public class BrushKit extends EventDispatcher
	{
		
		private static var _initialized:Boolean = false;
		private static var _availableBrushTypes:Vector.<String>;
		private static var _brushClassFromBrushType:Dictionary;
		
		public static function fromXML( xml:XML ):BrushKit
		{
			if (!_initialized ) init();
			
			var kit:BrushKit = new BrushKit(String(xml.@name));
			
			if ( _brushClassFromBrushType[ String(xml.@engine) ] )
			{
				var engine:AbstractBrush = new _brushClassFromBrushType[ String(xml.@engine) ]();
				kit.brushEngine = engine;
				
				if ( xml.pathengine[0] )
				{
					engine.setPathEngine(xml.pathengine[0]);
				}
				kit.brushEngine.updateParametersFromXML( xml );
				
			} else {
				throw("Brush type "+xml.@engine+" does not exist");
			}
			
			return kit;
		}
		
		private static function init():void
		{
			registerBrush( BrushType.WATER_COLOR, WaterColorBrush );
			registerBrush( BrushType.WATER_DAMAGE, WaterDamageBrush );
			registerBrush( BrushType.SPRAY_CAN, SprayCanBrush );
			registerBrush( BrushType.UNCOLORED_SPRAY_CAN, UncoloredSprayCanBrush );
			registerBrush( BrushType.DELAUNAY, DelaunayBrush );
			registerBrush( BrushType.SHATTER, ShatterBrush );
			registerBrush( BrushType.PENCIL, PencilBrush );
			registerBrush( BrushType.RIBBON, RibbonBrush );
			_initialized = true;
		}
		
		private static function registerBrush( brushName:String, brushClass:Class ):void {
			if( !_availableBrushTypes ) _availableBrushTypes = new Vector.<String>();
			if( !_brushClassFromBrushType ) _brushClassFromBrushType = new Dictionary();
			_availableBrushTypes.push( brushName );
			_brushClassFromBrushType[ brushName ] = brushClass;
		}
		
		
		private var _brushEngine:AbstractBrush;
		private var _brushName:String;

		public function BrushKit( name:String ) 
		{
			_brushName = name;
		}

		public function stopProgression() : void
		{
			_brushEngine.stopProgression();
		}

		public function activate( view : DisplayObject, context : Context3D, canvasModel : CanvasModel, textureManager : ITextureManager ):void
		{
			_brushEngine.activate(view, context, canvasModel, textureManager );
			PsykoSocket.addMessageCallback("ActiveBrushKit.*", this, onSocketMessage );
			sendBrushKitParameterSet();
		}
		
		public function deactivate():void
		{
			PsykoSocket.removeMessageCallback("ActiveBrushKit.*", this, onSocketMessage );
			_brushEngine.deactivate();
		}
		
		
		public function set brushEngine( value:AbstractBrush ):void
		{
			_brushEngine = value;
		}
		
		public function get brushEngine():AbstractBrush
		{
			return _brushEngine;
		}
		
		public function getParameterSet():XML
		{
			var result:XML = _brushEngine.getParameterSet([]);
			result.@name = _brushName;
			return result;
		}
		
		public function setBrushParameter( parameter:XML):void
		{
			var message:XML = <msg/>;
			message.appendChild(parameter);
			_brushEngine.updateParametersFromXML(message);
		}
		
		protected function onSocketMessage( message:XML ):void
		{
			var target:String = String( message.@target ).split(".")[1];
			switch ( target )
			{
				case "parameterChange":
					_brushEngine.updateParametersFromXML(message);
					dispatchEvent( new Event( Event.CHANGE ) );
				break;
				case "getParameterSet":
					sendBrushKitParameterSet();
					break;
				case "removePointDecorator":
					_brushEngine.pathManager.removePointDecoratorAt( int(message.@index) );
					dispatchEvent( new Event( Event.CHANGE ) );
				break;
				case "addPointDecorator":
					_brushEngine.pathManager.addPointDecorator(PointDecoratorFactory.getPathDecorator( String(message.@className) ) );
					sendBrushKitParameterSet();
					dispatchEvent( new Event( Event.CHANGE ) );
				break;
				case "movePointDecoratorIndex":
					_brushEngine.pathManager.movePointDecorator(int(message.@oldIndex), int(message.@newIndex) );
					dispatchEvent( new Event( Event.CHANGE ) );
				break;
				/*
				case "addShape":
					_brushEngine.addAvailableShape(message.@type);
					sendBrushKitParameterSet();
					dispatchEvent( new Event( Event.CHANGE ) );
					break;
				case "removeShapeAtIndex":
					_brushEngine.removeAvailableShapeAt(int(message.@index));
					sendBrushKitParameterSet();
					dispatchEvent( new Event( Event.CHANGE ) );
					break;
				*/
				default:
					throw("unknown target "+target );	
				break;
			}
		//	var ping:String = '<msg src="BrushKit.onSocketMessage" />';
		//	PsykoSocket.sendString( ping );
		}
		
		protected function sendBrushKitParameterSet():void
		{
			var message:XML = <msg src="ActiveBrushKit.parameterSet" />;
			message.appendChild(getParameterSet());
			PsykoSocket.sendString( message.toXMLString() );
		}
		
		/*
		public function get getActiveBrushShape():String {
			return _brushEngine.getParameter("Shapes").stringValue;
		}
		*/

		public function set canvasRect(canvasRect : Rectangle) : void
		{
			_brushEngine.pathManager.setCanvasRect(canvasRect);
		}
	}
}