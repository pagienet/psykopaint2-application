package net.psykosoft.psykopaint2.core.drawing.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class PsykoParameter extends EventDispatcher
	{
		// TODO: @Mario - let me know if you add parameters or if you need any ui component implementations
		public static const NumberParameter:int = 0; // slider
		public static const IntParameter:int = 1; // slider
		public static const NumberRangeParameter:int =2; // range slider
		public static const IntRangeParameter:int = 3; // range slider
		public static const StringParameter:int = 4; // text input TODO
		public static const NumberListParameter:int = 5; // combo box TODO
		public static const IntListParameter:int = 6; // combo box TODO
		public static const StringListParameter:int = 7; // combo box TODO minimalcomps for now, implement real combobox ( design is ready, component is not )
		public static const BooleanParameter:int = 8; // checkbox TODO: there seems to be a bug in the way the core handles parameter updates
		public static const BooleanListParameter:int = 9; // check box TODO: what is a boolean list? Mario: it's a list of checkboxes - probably never used
		public static const AngleParameter:int = 10; // angle control TODO: minimalcomps for now, implement real knob
		public static const AngleRangeParameter:int = 11; // double angle control TODO: using range slider for now
		public static const IconListParameter:int = 12; // works like a stringlist, but the type allows the view to pick a separate selection component
		
		
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
				case IconListParameter: return "IconListParameter";
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
		private var _showInUI:Boolean;
		
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
				case IconListParameter:
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
				case IconListParameter:
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
				dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		public function get booleanValue():Boolean
		{
			return _numberValue == 1;
		}
		
		public function set booleanValue( value:Boolean ):void
		{
			_numberValue = value ? 1 : 0;
			dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
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
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		public function get rangeValue():Number
		{
			return _numberValues[1] - _numberValues[0];
		}
		
		public function get stringValue():String
		{
			if ( type == StringListParameter  || type == IconListParameter)
			{
				return _stringValues[_index];
			}
			return _stringValue;
		}
		
		public function set stringValue( value:String ):void
		{
			_stringValue = value;
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		public function set minLimit( value:Number ):void
		{
			if ( type == AngleParameter || type == AngleRangeParameter ) value = value / 180 * Math.PI;
			_minLimit = value;
			if ( _numberValue < _minLimit ) _numberValue = _minLimit;
			if ( _numberValues )
			{
				if ( _numberValues[0] < _minLimit ) _numberValues[0] = _minLimit;
				if ( _numberValues[1] < _minLimit ) _numberValues[1] = _minLimit;
			}
		}
		
		public function get minLimit( ):Number
		{
			if ( type == AngleParameter || type == AngleRangeParameter) return _minLimit / Math.PI * 180;
			return _minLimit;
		}
		
		
		public function set maxLimit( value:Number ):void
		{
			if ( type == AngleParameter || type == AngleRangeParameter) value = value / 180 * Math.PI;
			_maxLimit = value;
			if ( _numberValue > _maxLimit ) _numberValue = _maxLimit;
			if ( _numberValues )
			{
				if ( _numberValues[0] > _maxLimit ) _numberValues[0] = _maxLimit;
				if ( _numberValues[1] > _maxLimit ) _numberValues[1] = _maxLimit;
			}
		}
		
		public function get maxLimit( ):Number
		{
			if ( type == AngleParameter || type == AngleRangeParameter) return _maxLimit / Math.PI * 180;
			return _maxLimit;
		}
		
		
		public function updateValueFromXML( message:XML ):void
		{
			
			if (  message.hasOwnProperty("@minValue") )
				minLimit = Number( message.@minValue );
			
			if (  message.hasOwnProperty("@maxValue") )
				maxLimit = Number( message.@maxValue );
			
			switch ( type )
			{
				case NumberParameter:
				case IntParameter:
					if (  message.hasOwnProperty("@value") )
						numberValue = Number( message.@value );
					break;
				case AngleParameter:
					if (  message.hasOwnProperty("@value") )
						degrees = Number( message.@value ) ;
					break;
				case NumberRangeParameter:
				case IntRangeParameter:
					if (  message.hasOwnProperty("@value") )
					{
						lowerRangeValue = upperRangeValue = Number( message.@value );
						trace("This is a range value decorator. Are you sure you want to set it via @value and not via @value1/@value2 ?");
					}
					if (  message.hasOwnProperty("@value1") )
						lowerRangeValue = Number( message.@value1 );
					
					if (  message.hasOwnProperty("@value2") )
						upperRangeValue = Number( message.@value2 );
					break;
				case AngleRangeParameter:
					if (  message.hasOwnProperty("@value1") )
						lowerDegreesValue = Number( message.@value1 );
					if (  message.hasOwnProperty("@value2") )
						upperDegreesValue = Number( message.@value2 );
					break;
				case StringParameter:
					if (  message.hasOwnProperty("@value") )
						stringValue = String(message.@value);
					break;
				case StringListParameter:
				case IconListParameter:
					if ( message.hasOwnProperty("@list") )
					{
						_stringValues = Vector.<String>(String( message.@list ).split(",") );
						_minLimit = 0;
						_maxLimit = _stringValues.length-1;
					}
					if ( message.hasOwnProperty("@index") )
					{
						index =  int( message.@index );
					}	
					break;
				case NumberListParameter:
				case IntListParameter:
				case BooleanListParameter:
					if ( message.hasOwnProperty("@list") )
					{
						_numberValues = Vector.<Number>(String( message.@list ).split(",") );
						_minLimit = 0;
						_maxLimit = _numberValues.length-1;
					}
					if ( message.hasOwnProperty("@index") )
					{
						index =  int( message.@index );
					}
					break;
				case BooleanParameter:
					if (  message.hasOwnProperty("@value") )
						booleanValue = int( message.@value ) == 1;
					break;
			}
			
			_showInUI = message.hasOwnProperty("@showInUI") && message.@showInUI == "1";
		}
		
		public function toXML( path:Array ):XML
		{
			var result:XML = <parameter id={id} type={type} path={path.join(".")} showInUI={_showInUI ? "1" : "0" } />
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
				case IconListParameter:
					result.@index = _index;
					result.@list = _stringValues.join(",");
					break;
				case BooleanParameter:
					result.@value = (_numberValue == 1 ? "1" : "0");
			}
			return result;
		}
			
	}
}