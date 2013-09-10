package net.psykosoft.psykopaint2.core.drawing.data
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.IPointDecorator;
	
	
	public class PsykoParameterProxy
	{
		public static const TYPE_VALUE_MAP:int = 0;
		public static const TYPE_DECORATOR_ACTIVATION:int = 1;
		public static const TYPE_PARAMETER_CHANGE:int = 2;
		
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
		private var compareValue:Number;
		private var indices:Vector.<int>;
		private var targetMappings:Vector.<Function>;
		private var targetOffsets:Vector.<Number>;
		private var targetFactors:Vector.<Number>;
		private var targetProperties:Vector.<String>;
		
		private var parameterXML:XML;
		private var condition:String;
		private const _applyArray:Array = [0,0,1,1];
		
		public var type:int;
		
		public static function fromXML(xml:XML):PsykoParameterProxy
		{
			var result:PsykoParameterProxy = new PsykoParameterProxy();
			if ( !xml.hasOwnProperty("@src" )) throw("PsykoParameterProxy requires @src attribute");
			if ( !xml.hasOwnProperty("@target" )) throw("PsykoParameterProxy requires @target attribute");
			if ( !xml.hasOwnProperty("@type" )) throw("PsykoParameterProxy requires @type attribute");
			
			result.parameterXML = xml;
			result.type = int(xml.@type);
			result.source_id = xml.@src;
			result.target_path = xml.@target;
			if ( xml.hasOwnProperty("@minValue" )) result.minValue = Number( xml.@minValue );
			if ( xml.hasOwnProperty("@maxValue" )) result.maxValue = Number( xml.@maxValue );
			if ( xml.hasOwnProperty("@compareValue" )) result.compareValue = Number( xml.@compareValue );
			if ( xml.hasOwnProperty("@value" )) result.value = Number( xml.@value );
			if ( xml.hasOwnProperty("@indices" )) result.indices = Vector.<int>(String( xml.@indices ).split(","));
			if ( xml.hasOwnProperty("@condition" )) result.condition = String( xml.@condition );
			
			if ( xml.hasOwnProperty("@targetOffsets" )) 
			{
				var mappingOffsets:Array = String( xml.@targetOffsets ).split(",");
				for ( i = 0; i < mappingOffsets.length; i++ )
				{
					result.targetOffsets[i] = Number( mappingOffsets[i] );
				}
			}
			if ( xml.hasOwnProperty("@targetFactors" )) 
			{
				var mappingFactors:Array = String( xml.@targetFactors ).split(",");
				for ( i = 0; i < mappingFactors.length; i++ )
				{
					result.targetFactors[i] = Number( mappingFactors[i] );
				}
			}
			if ( xml.hasOwnProperty("@targetProperties" )) 
			{
				var mappingProperties:Array = String( xml.@targetProperties ).split(",");
				for ( i = 0; i < mappingProperties.length; i++ )
				{
					result.targetProperties[i] = mappingProperties[i];
				}
			}
			if ( xml.hasOwnProperty("@targetMappings" )) 
			{
				var mappingIndices:Array = String( xml.@targetMappings ).split(",");
				for ( var i:int = 0; i < mappingIndices.length; i++ )
				{
					result.targetMappings[i] = mappingFunctions[int( mappingIndices[i] )];
				}
			} else {
				
				//default to linear mapping
				for ( i = 0; i < result.targetProperties.length; i++ )
				{
					result.targetMappings[i] = mappingFunctions[0];
				}
			}
			
			return result;
		}
			
		public function PsykoParameterProxy()
		{
			targetMappings   = new Vector.<Function>();
			targetOffsets    = new Vector.<Number>();
			targetFactors    = new Vector.<Number>();
			targetProperties = new Vector.<String>();
			indices          = new Vector.<int>();
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
					if ( parameter.type == PsykoParameter.NumberParameter || parameter.type == PsykoParameter.IntParameter )
					{
						var applyArray:Array = _applyArray;
						
						applyArray[0] = parameter.numberValue;
						
						for ( var i:int = 0; i < targetProperties.length; i++)
						{
							target_parameter[targetProperties[i]] = targetMappings[i].apply(null,applyArray) * targetFactors[i] + targetOffsets[i];
						}
					} else {
						throw("value mapping not yet implemented for parameter type "+parameter.type );
					}
					break;
				case TYPE_DECORATOR_ACTIVATION:
					if ( target_decorator == null ) throw("PsykoParameterProxy - target decorator not linked yet");
					target_decorator.active = conditionResult(parameter);
					break;
				case TYPE_PARAMETER_CHANGE:
					if ( target_parameter == null ) throw("PsykoParameterProxy - target parameter not linked yet");
					if ( conditionResult(parameter) ) target_parameter.updateValueFromXML( parameterXML );
					break;
			}
		}
		
		private function conditionResult( parameter:PsykoParameter ):Boolean
		{
			var result:Boolean = false;
			switch ( String( condition ) )
			{
				case CONDITION_LOWER_THAN_VALUE:
					result = isLower( parameter );
					break;
				case CONDITION_HIGHER_THAN_VALUE:
					result = isHigher( parameter );
					break;
				case CONDITION_EQUALS_VALUE:
					result = isEqual( parameter );
					break;
				case CONDITION_NOT_EQUALS_VALUE:
					result = isUnequal( parameter );
					break;
				case CONDITION_INSIDE_RANGE:
					result = isInRange( parameter );
					break;
				case CONDITION_OUTSIDE_RANGE:
					result = isOutOfRange( parameter );
					break;
				case CONDITION_TRUE:
					result = parameter.booleanValue;
					break;
				case CONDITION_FALSE:
					result = !parameter.booleanValue;
					break;
			}
			return result;
		}
		
		private function isEqual( parameter:PsykoParameter ):Boolean
		{
			switch ( parameter.type )
			{
				case PsykoParameter.StringListParameter:
				case PsykoParameter.NumberListParameter:
				case PsykoParameter.IconListParameter:	
					return indices.indexOf(parameter.index) > -1;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue == compareValue;
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
					return indices.indexOf(parameter.index) == -1
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue != compareValue;
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
					return parameter.index < compareValue;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue < compareValue;
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
					return parameter.index > compareValue;
					break;
				case PsykoParameter.NumberParameter:
				case PsykoParameter.IntParameter:
				case PsykoParameter.AngleParameter:	
					return parameter.numberValue > compareValue;
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
					return parameter.lowerRangeValue >= compareValue && parameter.upperRangeValue <= compareValue;
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
					return parameter.lowerRangeValue > compareValue || parameter.upperRangeValue < compareValue;
					break;
				
			}
			throw("PsykoParameterProxy : parameter type does not match condition");
			return false;
		}
	}
}