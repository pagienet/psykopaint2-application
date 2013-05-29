package net.psykosoft.psykopaint2.core.resources
{
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	use namespace texture_management;

	public class TextureProxy
	{
		private var _texture : Texture;
		private var _usageMark : Number = 0;
		private var _width : uint;
		private var _height : uint;
		private var _format : String;
		private var _isRenderTarget : Boolean;
		private var _mipData : Vector.<MipData>;
		private var _compressedByteArray : ByteArray;
		private var _compressedByteArrayOffset : uint;
		private var _listeners : Vector.<Listener>;
		private var _textureManager : ITextureManager;
		private var _persistent : Boolean = false;
		private var _size : int;

		public function TextureProxy(width : uint, height : uint, format : String, isRenderTarget : Boolean, textureManager : ITextureManager = null)
		{
			_textureManager = textureManager || FreeTextureManager.getInstance() as ITextureManager;
			_width = width;
			_height = height;
			_format = format;
			_isRenderTarget = isRenderTarget;
			_listeners = new Vector.<Listener>();
			_mipData = new Vector.<MipData>();
			_size = _width*_height*4 * 4/3;
		}

		public function get persistent() : Boolean
		{
			return _persistent;
		}

		public function set persistent(value : Boolean) : void
		{
			_persistent = value;
		}

		public function get isRenderTarget() : Boolean
		{
			return _isRenderTarget;
		}

		public function get texture() : TextureBase
		{
			// may need to replace this with a global property
			_usageMark = getTimer();
			if (!_texture) {
				_textureManager.initTexture(this);
				InitListeners();
			}
			return _texture;
		}

		public function dispose() : void
		{
			if (_texture) {
				DestroyListeners();
				_textureManager.freeTexture(this);
				_texture = null;
			}

			disposeMiplevels();
		}

		private function InitListeners() : void
		{
			for (var i : int = 0; i < _listeners.length; ++i) {
				var listener : Listener = _listeners[i];
				_texture.addEventListener(listener.type, listener.listener, listener.useCapture, listener.priority, listener.useWeakReference);
			}
		}

		private function DestroyListeners() : void
		{
			for (var i : int = 0; i < _listeners.length; ++i) {
				var listener : Listener = _listeners[i];
				_texture.removeEventListener(listener.type, listener.listener);
			}
		}

		public function get width() : uint
		{
			return _width;
		}

		public function get height() : uint
		{
			return _height;
		}

		public function get format() : String
		{
			return _format;
		}

		public function get size() : uint
		{
			// this is not guaranteed for compressed textures, but I don't think we're using them yet (and I don't think there's a way to get that)
			return _size;
		}

		public function uploadFromBitmapData(source : BitmapData, miplevel : uint = 0) : void
		{
			trace ("HON HON HON! If you're using this, you're making le mistake!");

			var mipData : MipData = getOrCreateMipData(miplevel);
			if (mipData.bitmapData) mipData.bitmapData.dispose();
			mipData.bitmapData = source.clone();
			mipData.byteArray = null;

			if (_texture)
				_texture.uploadFromBitmapData(source, miplevel);
		}

		public function uploadFromByteArray(data : ByteArray, byteArrayOffset : uint, miplevel : uint = 0) : void
		{
			trace ("HON HON HON! If you're using this, you're making le mistake!");

			var mipData : MipData = getOrCreateMipData(miplevel);
			if (mipData.bitmapData) mipData.bitmapData.dispose();
			mipData.bitmapData = null;
			mipData.byteArray = data;
			mipData.byteArrayOffset = byteArrayOffset;

			if (_texture)
				_texture.uploadFromByteArray(data, byteArrayOffset, miplevel);
		}

		public function uploadCompressedTextureFromByteArray(data : ByteArray, byteArrayOffset : uint, async : Boolean = false) : void
		{
			trace ("HON HON HON! If you're using this, you're making le mistake!");

			disposeMiplevels();
			_compressedByteArray = data;
			_compressedByteArrayOffset = byteArrayOffset;

			if (_texture)
				_texture.uploadCompressedTextureFromByteArray(_compressedByteArray, byteArrayOffset, async);
		}

		private function disposeMiplevels() : void
		{
			for (var i : int = 0; i < _mipData.length; ++i) {
				var mipData : MipData = _mipData[i];
				if (mipData.bitmapData) mipData.bitmapData.dispose();
			}

			_mipData.length = 0;
		}

		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			if (getListenerIndex(type, listener) >= 0) {
				_listeners.push(new Listener(type,  listener, useCapture, priority, useWeakReference));
				if (_texture)
					_texture.addEventListener(type,  listener, useCapture, priority, useWeakReference);
			}
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			var listenerIndex : int  = getListenerIndex(type, listener);
			if (listenerIndex >= 0) {
				_listeners.splice(listenerIndex, 1);
				if (_texture)
					_texture.removeEventListener(type, listener);
			}
		}

		public function dispatchEvent(event : Event) : Boolean
		{
			if (_texture)
				return _texture.dispatchEvent(event);

			return false;
		}

		public function hasEventListener(type : String) : Boolean
		{
			return false;
		}

		public function willTrigger(type : String) : Boolean
		{
			return false;
		}

		texture_management function setTexture(value : Texture) : void
		{
		    _texture = value;
			if (_texture) upload();
		}

		internal function get usageMark() : Number
		{
			return _usageMark;
		}

		private function upload() : void
		{
			if (_compressedByteArray) {
				_texture.uploadCompressedTextureFromByteArray(_compressedByteArray, _compressedByteArrayOffset);
				_compressedByteArray = null;
			}

			for (var i : int = 0; i < _mipData.length; ++i) {
				var mipData : MipData = _mipData[i];
				if (mipData) {
					if (mipData.bitmapData)
						_texture.uploadFromBitmapData(mipData.bitmapData, i);
					else if (mipData.byteArray)
						_texture.uploadFromByteArray(mipData.byteArray, mipData.byteArrayOffset, i);
				}
			}
		}

		private function getOrCreateMipData(miplevel : uint) : MipData
		{
			if (_mipData.length <= miplevel)
				_mipData.length = miplevel+1;

			if (!_mipData[miplevel]) {
				_mipData[miplevel] = new MipData();
				if (miplevel > 0) {
					var mipWidth : uint = _width / (1 << miplevel);
					var mipHeight : uint = _height / (1 << miplevel);
					if (mipWidth < 1) mipWidth = 1;
					if (mipHeight < 1) mipHeight = 1;
				}
			}
			return _mipData[miplevel];
		}



		private function getListenerIndex(type : String, listener : Function) : int
		{
			for (var i : int = 0; i < _listeners.length; ++i) {
				var listenerItem : Listener = _listeners[i];
				if (type == listenerItem.type && listener == listenerItem.listener)
					return i;
			}
			return -1;
		}
	}
}

import flash.display.BitmapData;
import flash.utils.ByteArray;


class Listener
{
	public var type : String;
	public var listener : Function;
	public var useCapture : Boolean = false;
	public var priority : int = 0;
	public var useWeakReference : Boolean = false;

	public function Listener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false)
	{
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
		this.priority = priority;
		this.useWeakReference = useWeakReference;
	}
}

class MipData
{
	public var bitmapData : BitmapData;
	public var byteArray : ByteArray;
	public var byteArrayOffset : uint;
}