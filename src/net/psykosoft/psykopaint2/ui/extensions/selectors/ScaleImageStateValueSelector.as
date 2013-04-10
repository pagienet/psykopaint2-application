/*
Feathers
Copyright 2012-2013 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package net.psykosoft.psykopaint2.ui.extensions.selectors
{

	import feathers.controls.Button;
	import feathers.skins.StateWithToggleValueSelector;

	import net.psykosoft.psykopaint2.ui.extensions.general.FixedSizeImage;

	import starling.display.BlendMode;

	import starling.display.Image;
	import starling.textures.Texture;

	/**
	 * Values for each state are Texture instances, and the manager attempts to
	 * reuse the existing Image instance that is passed in to getValueForState()
	 * as the old value by swapping the texture.
	 */
	public class ScaleImageStateValueSelector extends StateWithToggleValueSelector
	{
		/**
		 * Constructor.
		 */
		public function ScaleImageStateValueSelector()
		{
		}

		/**
		 * @private
		 */
		protected var _imageProperties:Object;

		/**
		 * Optional properties to set on the Image instance.
		 *
		 * @see starling.display.Image
		 */
		public function get imageProperties():Object
		{
			if(!this._imageProperties)
			{
				this._imageProperties = {};
			}
			return this._imageProperties;
		}

		/**
		 * @private
		 */
		public function set imageProperties(value:Object):void
		{
			this._imageProperties = value;
		}

		/**
		 * @private
		 */
		override public function setValueForState(value:Object, state:Object, isSelected:Boolean = false):void
		{
			if(!(value is Texture))
			{
				throw new ArgumentError("Value for state must be a Texture instance.");
			}
			super.setValueForState(value, state, isSelected);
		}

		/**
		 * @private
		 */
		override public function updateValue(target:Object, state:Object, oldValue:Object = null):Object
		{
			const texture:Texture = super.updateValue(target, state) as Texture;
			if(!texture)
			{
				return null;
			}

			if(oldValue is Image)
			{
				var image:FixedSizeImage = FixedSizeImage(oldValue);
				image.texture = texture;
				image.readjustSize();
			}
			else
			{
				image = new FixedSizeImage(texture);
			}

			for(var propertyName:String in this._imageProperties)
			{
				if(image.hasOwnProperty(propertyName))
				{
					var propertyValue:Object = this._imageProperties[propertyName];
					image[propertyName] = propertyValue;
				}
			}

			if( state == Button.STATE_DOWN ) {
				var scaling:Number = 0.9;
				var scaleOffset:Number = ( 1 - scaling ) / 2;
				image.scaleX = image.scaleY = 0.9;
				image.x = image.width * scaleOffset;
				image.y = image.height * scaleOffset;
			}
			else {
				image.scaleX = image.scaleY = 1;
				image.x = image.y = 0;
			}

			return image;
		}
	}
}
