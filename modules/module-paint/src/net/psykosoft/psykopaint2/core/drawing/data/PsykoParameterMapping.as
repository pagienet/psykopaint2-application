package net.psykosoft.psykopaint2.core.drawing.data
{
	import flash.events.Event;

	public class PsykoParameterMapping
	{
		private var _parameters:Vector.<PsykoParameter>;
		public var parameterProxies:Vector.<PsykoParameterProxy>;
		
		public static function fromXML( xml:XML ):PsykoParameterMapping
		{
	/*
			<parameterMapping>
				<parameter type="5" path="parameterMapping" label="Test" value="5" minValue="0" maxValue="10" showInUI="1"/>
				<proxy target="pathengine.pointdecorator_1.Factor" minValue="0" maxValue="5"/>
			  </parameterMapping>
*/
			var result:PsykoParameterMapping = new PsykoParameterMapping();
			for ( var i:int = 0; i < xml.parameter.length(); i++ )
			{
				result.addParameter( PsykoParameter.fromXML(xml.parameter[i] ) );
			}
			for ( i = 0; i < xml.proxy.length(); i++ )
			{
				result.addProxy( PsykoParameterProxy.fromXML(xml.proxy[i] ) );
			}
			return result;
		}
		
		public function PsykoParameterMapping()
		{
			_parameters = new Vector.<PsykoParameter>();
			parameterProxies = new Vector.<PsykoParameterProxy>();
		}
		
		public function addParameter( parameter:PsykoParameter):void
		{
			_parameters.push( parameter );
			parameter.addEventListener(Event.CHANGE, onParameterChanged );
		}
		
		protected function onParameterChanged(event:Event):void
		{
			for ( var i:int = 0; i < parameterProxies.length; i++ )
			{
				parameterProxies[i].update( PsykoParameter(event.target ) );
			}
			
		}
		
		public function addProxy( proxy:PsykoParameterProxy ):void
		{
			parameterProxies.push(proxy);
		}
		
		public function getParameterSet( vo:ParameterSetVO, showInUiOnly:Boolean ):void
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( !showInUiOnly || _parameters[i].showInUI > -1)
					vo.parameters.push( _parameters[i] );
			}
		}
		
	
		public function getParameterByPath(path:Array):PsykoParameter
		{
			var parameterID:String = path[1];
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if( _parameters[i].id == parameterID )
				{
					return _parameters[i];
				}
			}
			return null;
		}
	}
}