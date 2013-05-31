package net.psykosoft.psykopaint2.core.drawing.data
{
	public class PsykoParameter
	{
		public static const NumberParameter:int = 0; // slider
		public static const IntParameter:int = 1; // slider
		public static const NumberRangeParameter:int =2; // range slider
		public static const IntRangeParameter:int = 3; // range slider
		public static const StringParameter:int = 4; // text input TODO
		public static const NumberListParameter:int = 5; // Some kind of List - Horizontal Bar? TODO
		public static const IntListParameter:int = 6; // Some kind of List - Horizontal Bar? TODO
		public static const StringListParameter:int = 7; // combo box TODO minimalcomps for now, implement real combobox
		public static const BooleanParameter:int = 8; // checkbox TODO: there seems to be a bug in the way the core handles parameter updates
		public static const BooleanListParameter:int = 9; // check box TODO: what is a boolean list?
		public static const AngleParameter:int = 10; // angle control TODO: use minimal comps for now
		public static const AngleRangeParameter:int = 11; // double angle control TODO: see if minimal comps can offer something

		public static function getTypeName( type:int ):String {
			switch( type ) {
				case NumberParameter: return "NumberParameter";
				case IntParameter: return "IntParameter";
				case NumberRangeParameter: return "NumberRangeParameter";
				case IntRangeParameter: return "IntRangeParameter";
				case StringParameter: return "StringParameter";
				case IntListParameter: return "IntListParameter";
				case StringListParameter: return "StringListParameter";
				case BooleanParameter: return "BooleanParameter";
				case BooleanListParameter: return "BooleanListParameter";
				case AngleParameter: return "AngleParameter";
				case AngleRangeParameter: return "AngleRangeParameter";
			}
			return "unrecognized - have a look in PsykoParameter.as";
		}
		
		public static const LIMIT_MODE_IGNORE:String = "ignore";
		public static const LIMIT_MODE_CLAMP:String = "clamp";
		public static const LIMIT_MODE_WRAP:String = "wrap";
		
		public var type:int;
		
		public var id:String;
		private var _minLimit:Number;
		private var _maxLimit:Number;
		private var _numberValue:Number;
		private var _index:int;
		private var _stringValue:String;
		private var _numberValues:Vector.<Number>;
		private var _stringValues:Vector.<String>;
		
		public static function fromXML( data:XML ):PsykoParameter
		{
			switch ( int(data.@type) )
			{
				case NumberParameter:
				case IntParameter:
				case AngleParameter:
					//value, minValue, maxValue 
					return new PsykoParameter( int(data.@type), data.@id, Number( data.@value ),Number( data.@minValue ),Number( data.@maxValue ) );
					break;
				case NumberRangeParameter:
				case IntRangeParameter:
				case AngleRangeParameter:
					//value1, value2, minValue, maxValue 
					return new PsykoParameter( int(data.@type), data.@id, Number( data.@value1 ),Number( data.@value2 ),Number( data.@minValue ),Number( data.@maxValue ) );
					break;
				case StringParameter:
					//value
					return new PsykoParameter( int(data.@type), data.@id,String(data.@value) );
					break;
				case NumberListParameter:
				case IntListParameter:
				case BooleanListParameter:
					//index, array
					var list:Array = data.@list.split(",");
					for ( var i:int = 0; i < list.length; i++ )
					{
						list[i] = Number(list[i]);
					}
					return new PsykoParameter( int(data.@type), data.@id, int(data.@index), list );
					break;
				case StringListParameter:
					//index, array
					list = data.@list.split(",");
					return new PsykoParameter( int(data.@type), data.@id, int(data.@index), list );
				break;
				case BooleanParameter:
					//value, minValue, maxValue 
					return new PsykoParameter( int(data.@type), data.@id, int( data.@value ) == 1 );
					break;
			}
			
			return null;
		}
		
		public function PsykoParameter( type:int, id:String, ...args )
		{
			this.type = type;
			this.id = id;
			switch ( type )
			{
				case NumberParameter:
				case IntParameter:
					//value, minValue, maxValue 
					_numberValue = args[0];
					_minLimit = args[1];
					_maxLimit = args[2];
					break;
				case AngleParameter:
					//value in degrees, minValue in degrees, maxValue in degrees
					_numberValue = args[0] / 180 * Math.PI;
					_minLimit = args[1]  / 180 * Math.PI;
					_maxLimit = args[2]  / 180 * Math.PI;
					break;
				case NumberRangeParameter:
				case IntRangeParameter:
					//lowerRangeValue, upperRangeValue,  minValue, maxValue 
					_numberValues = new Vector.<Number>(2,true);
					_numberValues[0] = args[0];
					_numberValues[1] = args[1];
					_minLimit = args[2];
					_maxLimit = args[3];
					break;
				case AngleRangeParameter:
					//lowerRangeValue, upperRangeValue, minValue, maxValue 
					_numberValues = new Vector.<Number>(2,true);
					_numberValues[0] = args[0] / 180 * Math.PI;
					_numberValues[1] = args[1] / 180 * Math.PI;
					_minLimit = args[2]  / 180 * Math.PI;
					_maxLimit = args[3]  / 180 * Math.PI;
					break;
				case StringParameter:
					//value
					_stringValue =  args[0];
					break;
				case NumberListParameter:
				case IntListParameter:
					//index, array
					_index = args[0];
					_numberValues = Vector.<Number>( args[1]);
					_minLimit = 0;
					_maxLimit = _numberValues.length-1;
					break;
				case StringListParameter:
					//index, array
					_index = args[0];
					_stringValues = Vector.<String>( args[1] );
					_minLimit = 0;
					_maxLimit = _stringValues.length-1;
					break;
				case BooleanParameter:
					//value
					_numberValue =  args[0];
					break;
				case BooleanListParameter:
					//index, array
					_index = args[0];
					_numberValues = Vector.<Number>( args[1]);
					_minLimit = 0;
					_maxLimit = _numberValues.length-1;
					break;
			}
		}
		
		public function get numberValue():Number
		{
			if ( type == NumberListParameter || type == IntListParameter )
			{
				return _numberValues[_index];
			}
			return _numberValue;
		}
		
		public function set numberValue( value:Number ):void
		{
			if ( type == NumberParameter || type == IntParameter || type == AngleParameter)
			{
				if ( value < _minLimit ) value = _minLimit;
				if ( value > _maxLimit ) value = _maxLimit;
				_numberValue = value;
			} 
		}
		
		public function get degrees():Number
		{
			if ( type == NumberListParameter || type == IntListParameter )
			{
				return _numberValues[_index] / Math.PI * 180;
				
			}
			return _numberValue / Math.PI * 180;
		}
		
		public function set degrees( value:Number ):void
		{
			if ( type == NumberParameter || type == IntParameter || type == AngleParameter)
			{
				var v:Number = value / 180 * Math.PI;
				if ( v < _minLimit ) v = _minLimit;
				if ( v > _maxLimit ) v = _maxLimit;
				_numberValue = v;
			}
		}
		
		public function get booleanValue():Boolean
		{
			return _numberValue == 1;
		}
		
		public function set booleanValue( value:Boolean ):void
		{
			_numberValue = value ? 1 : 0;
		}
		
		public function get intValue():int
		{
			if ( type == NumberListParameter || type == IntListParameter )
			{
				return _numberValues[_index];
			}
			return int(_numberValue + 0.5);
		}
		
		public function set intValue( value:int ):void
		{
			if ( value < _minLimit ) value = _minLimit;
			if ( value > _maxLimit ) value = _maxLimit;
			_numberValue = value;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function set index( value:int ):void
		{
			if ( value < _minLimit ) value = _minLimit;
			if ( value > _maxLimit ) value = _maxLimit;
			_index = value;
		}
		
		public function get lowerRangeValue():Number
		{
			return _numberValues[0];
		}
		
		public function set lowerRangeValue( value:Number ):void
		{
			if ( value < _minLimit ) value = _minLimit;
			if ( value > _maxLimit ) value = _maxLimit;
			_numberValues[0] = value;
		}
		
		public function get upperRangeValue():Number
		{
			return _numberValues[1];
		}
		
		public function set upperRangeValue( value:Number ):void
		{
			if ( value < _minLimit ) value = _minLimit;
			if ( value > _maxLimit ) value = _maxLimit;
			_numberValues[1] = value;
		}
		
		
		public function get lowerDegreesValue():Number
		{
			return _numberValues[0]  / Math.PI * 180;
		}
		
		public function set lowerDegreesValue( value:Number ):void
		{
			var v:Number = value / 180 * Math.PI;
			if ( v < _minLimit ) v = _minLimit;
			if ( v > _maxLimit ) v = _maxLimit;
			_numberValues[0] = v;
		}
		
		public function get upperDegreesValue():Number
		{
			return _numberValues[1]  / Math.PI * 180;
		}
		
		public function set upperDegreesValue( value:Number ):void
		{
			var v:Number = value / 180 * Math.PI;
			if ( v < _minLimit ) v = _minLimit;
			if ( v > _maxLimit ) v = _maxLimit;
			_numberValues[1] = v;
		}
		
		public function get rangeValue():Number
		{
			return _numberValues[1] - _numberValues[0];
		}
		
		public function get stringValue():String
		{
			if ( type == StringListParameter )
			{
				return _stringValues[_index];
			}
			return _stringValue;
		}
		
		public function set stringValue( value:String ):void
		{
			_stringValue = value;
		}
		
		public function updateValueFromXML( message:XML ):void
		{
			switch ( type )
			{
				case NumberParameter:
				case IntParameter:
					numberValue = Number( message.@value );
					break;
				case AngleParameter:
					degrees = Number( message.@value ) ;
					break;
				case NumberRangeParameter:
				case IntRangeParameter:
					if (  message.hasOwnProperty("@value1") )
					{
						lowerRangeValue = Number( message.@value1 );
						upperRangeValue = Number( message.@value2 );
					} else{
						lowerRangeValue = upperRangeValue = Number( message.@value );
					}
					break;
				case AngleRangeParameter:
					lowerDegreesValue = Number( message.@value1 );
					upperDegreesValue = Number( message.@value2 );
					break;
				case StringParameter:
					stringValue = String(message.@value);
					break;
				case NumberListParameter:
				case IntListParameter:
				case BooleanListParameter:
				case StringListParameter:
					index =  int( message.@index );
					break;
				case BooleanParameter:
					booleanValue = int( message.@value ) == 1;
					break;
			}
		}
		
		public function toXML( path:Array ):XML
		{
			var result:XML = <parameter id={id} type={type} path={path.join(".")} />
			switch ( type )
			{
				case NumberParameter:
				case IntParameter:
					result.@minValue = _minLimit;
					result.@maxValue = _maxLimit;
					result.@value = _numberValue;
					break;
				case AngleParameter:
					result.@minValue = _minLimit / Math.PI * 180;
					result.@maxValue = _maxLimit / Math.PI * 180;
					result.@value = _numberValue / Math.PI * 180;
					break;
				case NumberRangeParameter:
				case IntRangeParameter:
					result.@minValue = _minLimit;
					result.@maxValue = _maxLimit;
					result.@value1 = _numberValues[0];
					result.@value2 = _numberValues[1];
					break;
				case AngleRangeParameter:
					result.@minValue = _minLimit / Math.PI * 180;
					result.@maxValue = _maxLimit / Math.PI * 180;
					result.@value1 = _numberValues[0] / Math.PI * 180;
					result.@value2 = _numberValues[1] / Math.PI * 180;
					break;
				case StringParameter:
					result.@value = _stringValue;
					break;
				case NumberListParameter:
				case IntListParameter:
				case BooleanListParameter:
					result.@index = _index;
					result.@list = _numberValues.join(",");
					break;
				case StringListParameter:
					result.@index = _index;
					result.@list = _stringValues.join(",");
					break;
				case BooleanParameter:
					result.@value = (_numberValue == 1);
			}
			return result;
		}
			
	}
}