// =================================================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Most of the color transformation math was taken from the excellent ColorMatrix class by
// Mario Klingemann: http://www.quasimondo.com/archives/000565.php -- THANKS!!!

package net.psykosoft.psykopaint2.core.drawing.colortransfer
{
    import com.quasimondo.geom.ColorMatrix;
    
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Program3D;

	// TODO: commented by li, we don't use starling anymore
//    import starling.filters.FragmentFilter;
//    import starling.textures.Texture;
    
    /** The ColorMatrixFilter class lets you apply a 4x5 matrix transformation on the RGBA color 
     *  and alpha values of every pixel in the input image to produce a result with a new set 
     *  of RGBA color and alpha values. It allows saturation changes, hue rotation, 
     *  luminance to alpha, and various other effects.
     * 
     *  <p>The class contains several convenience methods for frequently used color 
     *  adjustments. All those methods change the current matrix, which means you can easily 
     *  combine them in one filter:</p>
     *  
     *  <listing>
     *  // create an inverted filter with 50% saturation and 180° hue rotation
     *  var filter:ColorMatrixFilter = new ColorMatrixFilter();
     *  filter.invert();
     *  filter.adjustSaturation(-0.5);
     *  filter.adjustHue(1.0);</listing>
     *  
     *  <p>If you want to gradually animate one of the predefined color adjustments, either reset
     *  the matrix after each step, or use an identical adjustment value for each step; the 
     *  changes will add up.</p>
     */
		// TODO: commented by li, we don't use starling anymore
    public class ColorTransferFilter/* extends FragmentFilter*/
    {
		
		private static const LUMA_FACTORS:Vector.<Number> = new <Number>[0.2990,  0.5870,  0.1140,1];
		
        private var mShaderProgram:Program3D;
        
        private var mShaderMatrix1:Vector.<Number>; // offset in range 0-1, changed order
		private var mShaderMatrix2:Vector.<Number>; // offset in range 0-1, changed order
         private var threshold:Vector.<Number>;
		
        
        /** Creates a new ColorMatrixFilter instance with the specified matrix. 
         *  @param matrix: a vector of 20 items arranged as a 4x5 matrix.   
         */
        public function ColorTransferFilter(matrix:Vector.<Number>=null)
        {
            mShaderMatrix1 = new <Number>[];
			mShaderMatrix2 = new <Number>[];
			threshold  = new <Number>[0.5, 0, 1, 0];
        }
        
        /** @private */
		// TODO: commented by li, we don't use starling anymore
        /*protected override function createPrograms():void
        {
            // fc0-3: matrix1
            // fc4:  offset1
			// fc5-8: matrix2
			// fc9:  offset2
			// fc10: threshold, range, 1
			// fc11: luminance factors
            var fragmentProgramCode:String =
                "tex ft0, v0,  fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
                "m44 ft1, ft0, fc0              \n" + // multiply color with 4x4 matrix 1
				"add ft1, ft1, fc4              \n" + // add offset 1 
				"m44 ft2, ft0, fc5              \n" + // multiply color with 4x4 matrix 2
				"add ft2, ft2, fc9              \n" + // add offset 2
				"dp3 ft0.x, ft0, fc11           \n" + // calculate luminance 
				"sub ft0.x, ft0.x, fc10.x       \n" + // subtract threshold
				"mul ft0.x, ft0.x, fc10.y       \n" + // multiply with range
				"sat ft0.x, ft0.x 			    \n" +  // clamp
                "mul ft2, ft2, ft0.x 		    \n" + // multiply color 1 with factor
				"neg ft0.x, ft0.x               \n" +
				"add ft0.x, ft0.x, fc10.z       \n" +  // factor = 1-factor
				"mul ft1, ft1, ft0.x            \n" + // multiply color 1 with inverse factor
                "add oc, ft1, ft2               \n";  // add color1 and color2 and output
            
            mShaderProgram = assembleAgal(fragmentProgramCode);
        }*/
        
        /** @private */
		// TODO: commented by li, we don't use starling anymore
        /*protected override function activate(pass:int, context:Context3D, texture:Texture):void
        {
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mShaderMatrix1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, mShaderMatrix2);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, threshold);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 11, LUMA_FACTORS );
            context.setProgram(mShaderProgram);
        }*/
        
        // color manipulation
        public function updateSettings( colorMatrix1:ColorMatrix, colorMatrix2:ColorMatrix, threshold:Number, range:Number ):void
        {
            // the shader needs the matrix components in a different order, 
            // and it needs the offsets in the range 0-1.
			var m1:Array = colorMatrix1.matrix;
			mShaderMatrix1.length = 0;
            mShaderMatrix1.push(
				m1[0],  m1[1],  m1[2],  m1[3],
				m1[5],  m1[6],  m1[7],  m1[8],
				m1[10], m1[11], m1[12], m1[13], 
				m1[15], m1[16], m1[17], m1[18],
				m1[4] / 255.0,  m1[9] / 255.0,  m1[14] / 255.0,  
				m1[19] / 255.0
            );
			
			var m2:Array = colorMatrix2.matrix;
			mShaderMatrix2.length = 0;
			mShaderMatrix2.push(
				m2[0],  m2[1],  m2[2],  m2[3],
				m2[5],  m2[6],  m2[7],  m2[8],
				m2[10], m2[11], m2[12], m2[13], 
				m2[15], m2[16], m2[17], m2[18],
				m2[4] / 255.0,  m2[9] / 255.0,  m2[14] / 255.0,  
				m2[19] / 255.0
			);
			
			this.threshold[0] = (threshold - range *0.5 )/ 255.0;
			this.threshold[1] = 255 / range
        }
        
      
       
    }
}