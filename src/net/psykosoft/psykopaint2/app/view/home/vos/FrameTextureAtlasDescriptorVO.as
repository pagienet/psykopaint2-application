package net.psykosoft.psykopaint2.app.view.home.vos
{

	import flash.geom.Rectangle;

	public class FrameTextureAtlasDescriptorVO
	{
		public var width:Number;
		public var height:Number;
		public var tr:Rectangle;
		public var tl:Rectangle;
		public var br:Rectangle;
		public var bl:Rectangle;
		public var t:Rectangle;
		public var b:Rectangle;
		public var r:Rectangle;
		public var l:Rectangle;

		public function FrameTextureAtlasDescriptorVO( textureName:String, atlasXml:XML, textureWidth:Number, textureHeight:Number ) {
			width = textureWidth;
			height = textureHeight;
			var list:XMLList = atlasXml.SubTexture;
			var found:Boolean;
			for each( var item:XML in list ) {
				var itemName:String = item.@name;
				if( itemName.indexOf( textureName ) != -1 ) {
					found = true;
					var dump:Array = itemName.split( "_" );
					var prop:String = dump[ 1 ];
					this[ prop ] = new Rectangle( item.@x, item.@y, item.@width, item.@height );
				}
			}
			if( !found ) {
				throw new Error( "FrameTextureAtlasDescriptorVO - The texture " + textureName + " was not found in the atlas " + atlasXml.@imagePath + "." );
			}
		}

		public function toString():String {
			return "FrameTextureDescriptorVO - [ " +
					"width: " + width + ", " +
					"height: " + height + ", " +
					"tr: " + tr + ", " +
					"tl: " + tl + ", " +
					"br: " + br + ", " +
					"bl: " + bl + ", " +
					"b: " + b + ", " +
					"t: " + t + ", " +
					"r: " + r + ", " +
					"l: " + l +
					" ]";
		}
	}
}
