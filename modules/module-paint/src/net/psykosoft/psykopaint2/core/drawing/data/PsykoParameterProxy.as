package net.psykosoft.psykopaint2.core.drawing.data
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	
	import apparat.asm.LessThan;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;
	
	import org.osflash.signals.ISlot;

	public class PsykoParameterProxy
	{
		public static const TYPE_VALUE_MAP:int = 0;
		public static const TYPE_DECORATOR_ACTIVATION:int = 1;
		
		public static const CONDITION_LOWER_THAN_VALUE:String = "<";
		public static const CONDITION_HIGHER_THAN_VALUE:String = ">";
		public static const CONDITION_EQUALS_VALUE:String = "=";
		public static const CONDITION_NOT_EQUALS_VALUE:String = "!=";
		public static const CONDITION_INSIDE_RANGE:String = "><";
		public static const CONDITION_OUTSIDE_RANGE:String = "<>";
		public static const CONDITION_TRUE:String = "1";
		public static const CONDITION_FALSE:String = "0";
		
		static private const mappingFunctions:Vector.<Function> = Vector.<Function>([Linear.easeNone,Quad.easeIn,Quad.easeInOut,Quad.easeOut, Quart.easeIn,Quart.easeInOut,Quart.easeOut, Quint.easeIn,Quint.easeInOut,Quint.easeOut,Expo.easeIn, Expo.easeInOut, Expo.easeOut, Circ.easeIn,Circ.easeInOut, Circ.easeOut ]);
		
		public var target_path:String;
		
		private var source_id:String;
		private var target_parameter:PsykoParameter;
		private var target_decorator:IPointDecorator;
		
		private var minValue:Number;
		private var maxValue:Number;
		private var value:Number;
		private var index:int;
		private var mapping:Function;
		
		private var condition:String;
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
			if ( xml.hasOwnProperty("@value" )) result.value = Number( xml.@value );
			if ( xml.hasOwnProperty("@index" )) result.index = int( xml.@index );
			if ( xml.hasOwnProperty("@condition" )) result.condition = String( xml.@condition );
			if ( xml.hasOwnProperty("@mapping" )) result.mapping = mappingFunctions[int( xml.@mapping )];
				
			return result;
		}
			
		public function PsykoParameterProxy()
		{
			mapping = mappingFunctions[0];
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
			switch ( type )
			{
				case TYPE_VALUE_MAP:
					if ( target_parameter == null ) throw("PsykoParameterProxy - target parameter not linked yet");
					break;
				case TYPE_DECORATOR_ACTIVATION:
					if ( target_decorator == null ) throw("PsykoParameterProxy - target decorator not linked yet");
					switch ( String( condition ) )
					{
						case CONDITION_LOWER_THAN_VALUE:
							target_decorator.active = isLower( parameter );
							break;
						case CONDITION_HIGHER_THAN_VALUE:
							target_decorator.active = isHigher( parameter );
							break;
						case CONDITION_EQUALS_VALUE:
							target_decorator.active = isEqual( parameter );
							break;
						case CONDITION_NOT_EQUALS_VALUE:
							target_decorator.active = isUnequal( parameter );
							break;
						case CONDITION_INSIDE_RANGE:
							target_decorator.active = isInRange( parameter );
							break;
						case CONDITION_OUTSIDE_RANGE:
							target_decorator.active = isOutOfRange( parameter );
							break;
						case CONDITION_TRUE:
							target_decorator.active = parameter.booleanValue;
							break;
						case CONDITION_FALSE:
							target_decorator.active = !parameter.booleanValue;
							break;
					}
					break;
				
			}
		}
		
		private function isEqual( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.StringListParameter:
				case PsykoParameter.NumberListParameter:
				case PsykoParameter.IconListParameter:	
					return parameter.index == index;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue == value;
					break;
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
		
		private function isUnequal( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.StringListParameter:
				case PsykoParameter.NumberListParameter:
				case PsykoParameter.IconListParameter:	
					return parameter.index != index;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue != value;
					break;
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
		
		
		private function isLower( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.StringListParameter:
				case PsykoParameter.NumberListParameter:
				case PsykoParameter.IconListParameter:	
					return parameter.index < value;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue < value;
					break;
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
		
		private function isHigher ( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.StringListParameter:
				case PsykoParameter.NumberListParameter:
				case PsykoParameter.IconListParameter:	
					return parameter.index > value;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue > value;
					break;
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
		
		private function isInRange ( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.NumberRangeParameter:
				case PsykoParameter.IntRangeParameter:
				case PsykoParameter.AngleRangeParameter:
					return parameter.lowerRangeValue >= value && parameter.upperRangeValue <= value;
					break;
				
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
		
		private function isOutOfRange ( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.NumberRangeParameter:
				case PsykoParameter.IntRangeParameter:
				case PsykoParameter.AngleRangeParameter:
					return parameter.lowerRangeValue > value || parameter.upperRangeValue < value;
					break;
				
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
	}
}