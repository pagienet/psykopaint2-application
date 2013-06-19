package net.psykosoft.psykopaint2.core.drawing.data
{
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;

	public class PsykoParameterProxy
	{
		public static const TYPE_VALUE_MAP:int = 0;
		public static const TYPE_DECORATOR_ACTIVATION:int = 1;
		
		public var target_path:String;
		
		private var source_id:String;
		private var target_parameter:PsykoParameter;
		private var target_decorator:IPointDecorator;
		
		private var minValue:Number;
		private var maxValue:Number;
		public var type:int;
		
		public static function fromXML(xml:XML):PsykoParameterProxy
		{
			var result:PsykoParameterProxy = new PsykoParameterProxy();
			if ( !xml.hasOwnProperty("@src" )) throw("PsykoParameterProxy requires @src attribute");
			if ( !xml.hasOwnProperty("@target" )) throw("PsykoParameterProxy requires @target attribute");
			if ( !xml.hasOwnProperty("@type" )) throw("PsykoParameterProxy requires @type attribute");
			
			result.type = int(xml.@type);
			result.source_id = xml.@src;
			result.target_path = xml.@target;
			if ( xml.hasOwnProperty("@minValue" )) result.minValue = Number( xml.@minValue );
			if ( xml.hasOwnProperty("@maxValue" )) result.maxValue = Number( xml.@maxValue );
						
			return result;
		}
			
		public function PsykoParameterProxy()
		{
		}
		
		public function linkTargetParameter( parameter:PsykoParameter ):void
		{
			target_parameter = parameter;
		}
		
		public function linkTargetDecorator( decorator:IPointDecorator ):void
		{
			target_decorator = decorator;
			
		}
		
		public function update( parameter:PsykoParameter ):void
		{
			if ( parameter.id != source_id ) return;
			if ( target_parameter == null ) throw("PsykoParameterProxy - target parameter not linked yet");
			
		}
		
	}
}