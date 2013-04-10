/*
 Copyright 2012-2013 Joshua Tynjala

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
*/
package net.psykosoft.psykopaint2.ui.extensions.selectors
{

	import feathers.controls.Button;

	import flash.utils.Dictionary;

	/**
	 * Maps a component's states to values, perhaps for one of the component's
	 * properties such as a skin or text format.
	 */
	public class ScaleStateValueSelector
	{
		/**
		 * Constructor.
		 */
		public function ScaleStateValueSelector()
		{
		}

		/**
		 * @private
		 * Stores the values for each state.
		 */
		protected var stateToValue:Dictionary = new Dictionary(true);

		/**
		 * If there is no value for the specified state, a default value can
		 * be used as a fallback.
		 */
		public var defaultValue:Object;

		/**
		 * Stores a value for a specified state to be returned from
		 * getValueForState().
		 */
		public function setValueForState(value:Object, state:Object):void
		{
			this.stateToValue[state] = value;
		}

		/**
		 * Clears the value stored for a specific state.
		 */
		public function clearValueForState(state:Object):Object
		{
			const value:Object = this.stateToValue[state];
			delete this.stateToValue[state];
			return value;
		}

		/**
		 * Returns the value stored for a specific state.
		 */
		public function getValueForState(state:Object):Object
		{
			return this.stateToValue[state];
		}

		/**
		 * Returns the value stored for a specific state. May generate a value,
		 * if none is present.
		 *
		 * @param target		The object receiving the stored value. The manager may query properties on the target to customize the returned value.
		 * @param state			The current state.
		 * @param oldValue		The previous value. May be reused for the new value.
		 */
		public function updateValue(target:Object, state:Object, oldValue:Object = null):Object
		{
			var value:Object = this.stateToValue[state];
			if(!value)
			{
				value = this.defaultValue;
			}
			if( state == Button.STATE_DOWN || state == Button.STATE_HOVER ) {
				value[ "scaleX" ] = value[ "scaleY" ] = 0.25;
				trace( this, "scale down" );
			}
			else {
				value[ "scaleX" ] = value[ "scaleY" ] = 1;
				trace( this, "scale up" );
			}
			return value;
		}
	}
}
