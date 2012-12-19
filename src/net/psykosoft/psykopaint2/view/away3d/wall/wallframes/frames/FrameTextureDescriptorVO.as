package net.psykosoft.psykopaint2.view.away3d.wall.wallframes.frames
{

	public class FrameTextureDescriptorVO
	{
		public var textureWidth:Number;
		public var textureHeight:Number;
		public var imageWidth:Number;
		public var imageHeight:Number;
		public var paintingAreaWidth:Number;
		public var paintingAreaHeight:Number;
		public var paintingAreaX:Number;
		public var paintingAreaY:Number;

		public function FrameTextureDescriptorVO(
				imageWidth:Number, imageHeight:Number,
				paintingAreaX:Number, paintingAreaY:Number,
				paintingAreaWidth:Number, paintingAreaHeight:Number ) {
			this.imageWidth = imageWidth;
			this.imageHeight = imageHeight;
			this.paintingAreaX = paintingAreaX;
			this.paintingAreaY = paintingAreaY;
			this.paintingAreaWidth = paintingAreaWidth;
			this.paintingAreaHeight = paintingAreaHeight;
		}

		public function toString():String {
			return "FrameTextureDescriptorVO - [ textureWidth: " + textureWidth + ", "
			+ "textureHeight: " + textureHeight + ", "
			+ "imageWidth: " + imageWidth + ", "
			+ "imageHeight: " + imageHeight + ", "
			+ "paintingAreaWidth: " + paintingAreaWidth + ", "
			+ "paintingAreaHeight: " + paintingAreaHeight + ", "
			+ "paintingAreaX: " + paintingAreaX + ", "
			+ "paintingAreaY: " + paintingAreaY + " ]."
		}
	}
}
