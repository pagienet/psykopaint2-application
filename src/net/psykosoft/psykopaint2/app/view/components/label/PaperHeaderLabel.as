package net.psykosoft.psykopaint2.app.view.components.label
{

	
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.app.managers.assets.Fonts;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.utils.scale.Scale3Image;
	import net.psykosoft.psykopaint2.utils.scale.Scale3Texture;
	import net.psykosoft.utils.MathUtil;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	
	public class PaperHeaderLabel extends Sprite
	{
		private var _skinTextures:Scale3Texture;
		private var _labelImage:Scale3Image;
		
		private var _textfield :TextField;
		private var _width:Number=100;
		
		
		public function PaperHeaderLabel()
		{
			super();
			
			// Scale 9 bg texture for button labels.
			_skinTextures = new Scale3Texture( Psykopaint2Ui.instance.footerAtlas.getTexture( "label" ), 16, 63, Scale3Texture.DIRECTION_HORIZONTAL );
			_labelImage = new Scale3Image(_skinTextures);
			this.addChild(_labelImage); 
			_width = _labelImage.width;
		//	_labelImage.flatten();
			//_labelImage.clipRect = new Rectangle(0,0,200,50);
			
			
			_textfield = new TextField(200,_labelImage.height,"0",Fonts.Warugaki,20,0x333333);
			this.addChild(_textfield);
			//_textfield.x = _labelImage.width/2 - _textfield.width/2;
			_textfield.y = 1;
			
			
			//CREATE RANDOM COLOR
			var filter:ColorMatrixFilter = new ColorMatrixFilter();
			filter.adjustHue( MathUtil.rand( -1, 1 ) );
			filter.adjustSaturation( MathUtil.rand( -1, 1 ) );
			//_labelImage.filter = filter;
			//_labelImage.flatten();
			
			
		}
		
		
		override public function set width (value:Number):void{
			_width = value; 
			trace("[PaperHeaderLabel] width = "+value);
			_textfield.x = value/2 - _textfield.width/2;
			_labelImage.width=value;
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		override public function get width ():Number{
			return _width;
		}
		
		public function setLabel(value:String):void{
			trace("[PaperHeaderLabel] setLabel = "+value);
			_textfield.text = (value=="")?" ":value ;
			//CHANGE PAPER SIZE 
			trace("[PaperHeaderLabel] _textfield.textBounds.width = "+_textfield.textBounds.width);

			width = _textfield.textBounds.width+50;
		}
		
		
	}
}