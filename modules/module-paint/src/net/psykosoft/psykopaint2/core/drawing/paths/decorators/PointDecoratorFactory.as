package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import flash.utils.Dictionary;
	
	import net.psykosoft.psykopaint2.core.resources.PsykoSocket;

	public class PointDecoratorFactory
	{
		private static var _availableDecoratorTypes:Object;
		private static var _decoratorClassFromBrushType:Dictionary;
		private static var _initialized:Boolean;
		
		static private function init():void
		{
			registerDecorator( PointDecoratorType.CIRCULAR, CircularRotationDecorator );
			registerDecorator( PointDecoratorType.GRID, GridDecorator );
			registerDecorator( PointDecoratorType.PARTICLE, ParticleDecorator );
			registerDecorator( PointDecoratorType.SPAWN, SpawnDecorator );
			registerDecorator( PointDecoratorType.SPLATTER, SplatterDecorator );
			registerDecorator( PointDecoratorType.ROTATE, RotationDecorator );
			registerDecorator( PointDecoratorType.COLOR, ColorDecorator );
			registerDecorator( PointDecoratorType.CONDITIONAL, ConditionalDecorator );
			registerDecorator( PointDecoratorType.END_CONDITIONAL, EndConditionalDecorator );
			registerDecorator( PointDecoratorType.STATIONARY, StationaryDecorator );
			registerDecorator( PointDecoratorType.SIZE, SizeDecorator );
			
			_initialized = true;
			
			sendAvailableDecorators();
			PsykoSocket.addMessageCallback("PointDecoratorFactory.getAvailableDecorators",PointDecoratorFactory, onSocketMessage );
		}
		
		private static function registerDecorator( decoratorName:String, decoratorClass:Class ):void 
		{
			if( !_availableDecoratorTypes ) _availableDecoratorTypes = new Vector.<String>();
			if( !_decoratorClassFromBrushType ) _decoratorClassFromBrushType = new Dictionary();
			_availableDecoratorTypes.push( decoratorName );
			_decoratorClassFromBrushType[ decoratorName ] = decoratorClass;
		}
		
		static public function fromXML( data:XML ):IPointDecorator
		{
			if (!_initialized ) init();
			var className:String = data.name().localName;
			var decorator:IPointDecorator = new _decoratorClassFromBrushType[className]();
			decorator.updateParametersFromXML(data);
			return decorator;
		}
		
		static public function getPathDecorator( className:String ):IPointDecorator
		{
			if (!_initialized ) init();
			var decorator:IPointDecorator = new _decoratorClassFromBrushType[className]();
			return decorator;
			
		}
		
		static private function sendAvailableDecorators():void
		{
			var answer:XML = <msg src="PointDecoratorFactory.sendAvailableDecorators" />;
			for ( var i:* in _availableDecoratorTypes )
			{
				answer.appendChild(<decorator id={_availableDecoratorTypes[i]} />);
			}
			PsykoSocket.sendString( answer.toXMLString() );
		}
		
		static private function onSocketMessage( message:XML):void
		{
			sendAvailableDecorators()
		}
	}
}