package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.ClassicPsykoBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.DelaunayBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.DrawingApiBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.HitTestBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.PencilBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.RibbonBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.ShatterBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SketchBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.UncoloredSprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterDamageBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

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
				
				for ( var i:int = 0; i < xml.parameterMapping.length(); i++ )
				{
					kit.addParameterMappingFromXML( xml.parameterMapping[i] );
				}
				
				if ( xml.pathengine[0] )
				{
					engine.setPathEngine(xml.pathengine[0]);
				}
				kit.brushEngine.updateParametersFromXML( xml );
				
				kit.linkParameterMappings();
				
				
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
			registerBrush( BrushType.SKETCH, SketchBrush );
			registerBrush( BrushType.BLOB, DrawingApiBrush );
			registerBrush( BrushType.HITTEST, HitTestBrush );
			registerBrush( BrushType.CLASSIC_PSYKO, ClassicPsykoBrush );
			_initialized = true;
		}
		
		private static function registerBrush( brushName:String, brushClass:Class ):void {
			if( !_availableBrushTypes ) _availableBrushTypes = new Vector.<String>();
			if( !_brushClassFromBrushType ) _brushClassFromBrushType = new Dictionary();
			_availableBrushTypes.push( brushName );
			_brushClassFromBrushType[ brushName ] = brushClass;
		}
		
		public static function dispose():void
		{
			_availableBrushTypes = null;
		 	_brushClassFromBrushType = null;
			_initialized = false;
		}
		
		private var _brushEngine:AbstractBrush;
		private var _brushName:String;
		private var _parameterMappings:Vector.<PsykoParameterMapping>;
		

		public function BrushKit( name:String ) 
		{
			_brushName = name;
			_parameterMappings = new Vector.<PsykoParameterMapping>();
		}

		public function stopProgression() : void
		{
			_brushEngine.stopProgression();
		}

		public function activate( view : DisplayObject, context : Context3D, canvasModel : CanvasModel, renderer : CanvasRenderer, paintSettingsModel : UserPaintSettingsModel):void
		{
			_brushEngine.activate(view, context, canvasModel, renderer, paintSettingsModel);
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				PsykoSocket.addMessageCallback("ActiveBrushKit.*", this, onSocketMessage );
				sendBrushKitParameterSet();
			}
		}
		
		public function deactivate():void
		{
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				PsykoSocket.removeMessageCallback("ActiveBrushKit.*", this, onSocketMessage );
			}
			_brushEngine.deactivate();
		}

		public function dispose():void
		{
			_brushEngine.dispose();
		}
		
		public function set brushEngine( value:AbstractBrush ):void
		{
			_brushEngine = value;
		}
		
		public function get brushEngine():AbstractBrush
		{
			return _brushEngine;
		}
		
		public function getParameterSetAsXML():XML
		{
			var result:XML = _brushEngine.getParameterSetAsXML([]);
			result.@name = _brushName;
			return result;
		}
		
		public function getParameterSet( showInUIOnly:Boolean = true):ParameterSetVO
		{
			var vo:ParameterSetVO = new ParameterSetVO(_brushName);
			for ( var i:int = 0; i < _parameterMappings.length; i++ )
			{
				_parameterMappings[i].getParameterSet( vo, showInUIOnly );
			}
			_brushEngine.getParameterSet(vo,showInUIOnly);
			return vo;
		}
		
		public function addParameterMappingFromXML( xml:XML ):void
		{
			_parameterMappings.push( PsykoParameterMapping.fromXML( xml ));
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
			message.appendChild(getParameterSetAsXML());
			PsykoSocket.sendString( message.toXMLString() );
			
		}
		
		/*
		public function get getActiveBrushShape():String {
			return _brushEngine.getParameter("Shapes").stringValue;
		}
		*/

		public function setCanvasMatrix(matrix : Matrix) : void
		{
			_brushEngine.pathManager.setCanvasMatrix(matrix);
		}
		
		public function linkParameterMappings():void
		{
			for ( var i:int = 0; i < _parameterMappings.length; i++ )
			{
				var mapping:PsykoParameterMapping = _parameterMappings[i];
				for ( var j:int = 0; j < mapping.parameterProxies.length; j++ )
				{
					switch ( mapping.parameterProxies[j].type )
					{
						case PsykoParameterProxy.TYPE_VALUE_MAP:
						case PsykoParameterProxy.TYPE_PARAMETER_CHANGE:
							var parameter:PsykoParameter = getParameterByPath(mapping.parameterProxies[j].target_path );
							if ( parameter == null ) throw( "BrushKit.linkParameterMappings: "+mapping.parameterProxies[j].target_path+" not found");
							mapping.parameterProxies[j].linkTargetParameter(parameter);
							break;
						case PsykoParameterProxy.TYPE_DECORATOR_ACTIVATION:
							var decorator:IPointDecorator = brushEngine.getDecoratorByPath(mapping.parameterProxies[j].target_path );
							if ( decorator == null ) throw( "BrushKit.linkParameterMappings: "+mapping.parameterProxies[j].target_path+" not found");
							mapping.parameterProxies[j].linkTargetDecorator(decorator);
							break;
					}
				}
			}
			
		}
		
		private function getParameterByPath(target_path:String):PsykoParameter
		{
			var path:Array = target_path.split(".");
			if ( path[0] == "parameterMapping" ) 
			{
				for ( var i:int = 0; i < _parameterMappings.length; i++ )
				{
					var parameter:PsykoParameter =  _parameterMappings[i].getParameterByPath( path );
					if ( parameter != null ) return parameter;
				}
				throw("BrushKit.getParameterByPath "+target_path+" not found");
			}
			return _brushEngine.getParameterByPath(path);
		}
		
		public function get strokeInProgress():Boolean
		{
			return _brushEngine.pathManager.strokeInProgress;
		}
	}
}