package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	public class AbstractPointDecorator implements IPointDecorator
	{
		protected var _parameters:Vector.<PsykoParameter>;
		
		public function AbstractPointDecorator()
		{
			_parameters = new Vector.<PsykoParameter>();
		}
		
		public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			throw("override this");
			return null;
		}
		
		public function compare( points:Vector.<SamplePoint>, manager:PathManager ):Vector.<Vector.<SamplePoint>>
		{
			var result:Vector.<Vector.<SamplePoint>> = new Vector.<Vector.<SamplePoint>>(2,true);
			result[0] = points;
			return result;
		}
		
		public function getParameterSetAsXML( path:Array ):XML
		{
			throw("override this");
			return null;
		}
		
		public function getParameterSet( vo:ParameterSetVO, showInUiOnly:Boolean  ):void
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( !showInUiOnly || _parameters[i].showInUI )
					vo.parameters.push( _parameters[i] );
			}
			
		}
		
		public function updateParametersFromXML(message:XML):void
		{
			for ( var j:int = 0; j < message.parameter.length(); j++ )
			{
				var parameter:XML = message.parameter[j];
				var parameterID:String = String( parameter.@id );
				for ( var i:int = 0; i < _parameters.length; i++ )
				{
					if( _parameters[i].id == parameterID )
					{
						_parameters[i].updateValueFromXML(parameter);
					}
				}
			}
		}
		
		public function hasActivePoints():Boolean
		{
			return false;
		}
		
		public function clearActivePoints():void
		{
			
		}
	}
}