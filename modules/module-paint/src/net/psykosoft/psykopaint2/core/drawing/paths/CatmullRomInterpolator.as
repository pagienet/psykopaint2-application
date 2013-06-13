package net.psykosoft.psykopaint2.core.drawing.paths
{
	
	
	// 
	// -------------------------INTERPOLATION MINI GUIDE-------------------------
	// 
	// This is not a tutorial on interpolation. It shows a very common algorithm used
	// for interpolation which I made general purpose to compare several
	// interpolation types.  I added comments to explain some subtle aspects.
	//
	// I included some common types; Bézier, B-spline and Catmul-Rom. Some others I
	// ran across are; parabolic, simple cubic, Hermite and beta with tension & bias.
	// I completely derived the linear basis matrix myself (big deal].
	//
	// I also derived the Kochanek-Bartels from their 84 SIGGRAPH paper to provide
	// global control of tension, bias, continuity  (it//s been 25 years since I//ve
	// done matrix math so it took a few passes]. NO NURBS, I haven//t gotten in that
	// deep.
	//
	// I am not a math major nor an expert on splines and interpolation.  For the
	// last 2-1/2 years I read comp.graphics.algorithms, did some searches and
	// grabbed related things.  In Jan. //96, 4 months ago,  I decided to finally code
	// something and found that it was rather simple, thanks mostly to Leon DeBoer//s
	// posting.
	//
	// This routine does interpolation on a 2D list in the array; paddedData(c,n) where c=1
	// for the X coordinate, c=2 for Y and "n" the vector number. The same type of
	// interpolation is done on both X and Y coordinates though this is not required
	// in general and some interesting effects may be possible by using different
	// interpolation types for the dimensions - room for a little art. There are
	// comments for going to more dimensions later.  I set up this routine to study
	// the interpolation types and debug the code with the goal of moving to key
	// frame animation.
	//
	// There is a problem with terminology which I will now define.  Since Laser
	// (light show) Graphics is "vector" graphics, the coordinate sets (X,Y here) are
	// called vectors.  As this code is in my image editor, I use that term.  I think
	// I use both vector and control point in my comments.  They are the same.  This
	// algorithm considers all input image vectors as control points, even for
	// Hermite (once you understand the Hermite, you//ll see why this is incorrect for
	// it].  For key frame animation, the input control points are called key frames
	// or "keys".
	//
	// This is parametric interpolation, which means that the coordinate values are
	// interpolated vs. a parameter, in this case j.  Y is NOT interpolated as a
	// function of X as we might think to do.
	//
	// Because some types need data points before and after an interval in order to
	// calculate a curve, the first and last vectors need extra data.  A common
	// solution is simply to repeat the end vectors to provide the data.  This is
	// done here.  This forces the curve to always hit the 1st and last vectors.
	// This along with the way each type works can confuse what is going on. The
	// extra values could be made changeable to gain more control of the curve at the
	// end vectors.
	//
	// This is a general purpose routine, a single interpolation type won//t need all
	// the terms to be calculated.  Any basis matrix entry of zero means that the
	// corresponding term in the coef. equation can be removed.  An entire zero row
	// means that the corresponding power of t calculation can be dropped. This
	// routine calculates the polynomial equation in matrix form;
	// 
	//                                        | n-1 |
	//      1                                 | n   |           Steve Noskowicz
	// p = --- * [t^3  t^2  t  1] * [basis] * | n+1 |         Q10706@email.mot.com
	//      D                                 | n+2 |          May-13;Nov-25 1996
	// 
	// Entry conditions (if I remember everything);
	// * Arrays subscripts start at 1, not zero.
	// * The first vector is in paddedData(c,2].  paddedData(c,1) is the extra n-1 data.
	// * The last vector is in paddedData(c,p].
	// * interPts is the number of NEW points added "between" key points as t goes
	//   0-->1.
	//
	// NOTE;
	// For types which hit the control points (linear, cubic, Catmul-Rom), when t=0
	// (or 1) control vectors are being "re-calculated".  For these types, time can
	// be saved by eliminating those calculations and passing the original vectors
	// through.  Also, if t goes to 1, you are double calculating.
	//
	/*
	// type is used for selecting the basis matrix.
	
	Spline1;   type=1 GOTO Spline  // CatMul
	Spline2;   type=2 GOTO Spline  // B-Spline
	Spline3;   type=3 GOTO Spline  // Parabolic
	Spline4;   type=4 GOTO Spline  // Bézier (cubic)
	Spline5;   type=5 GOTO Spline  // Linear Interp
	Spline6;   type=6 GOTO Spline  // Hermite
	Spline7;   type=7 GOTO Spline  // Beta with Tension & Bias
	Spline8;   type=8 GOTO Spline  // Simple Cubic
	Spline9;   type=9 GOTO Spline  // Kochanek-Bartels, the Holy Grail.
	Spline10;  type=10; GOTO Spline  // Bezier (quadratic)
	
	Spline;
	*/
	
	public class CatmullRomInterpolator
	{
		
		public function CatmullRomInterpolator()
		{
		}


		
		public static function options( type:int ):Object
		{
			var result:Object = { bias:false, tension:false, continuity:false, interpolationSteps:true, useForwardDiff:false, delta:0.5 };
			return result;
		}
		
		
		public static function interpolate(  pathEngine:IPathEngine,  startIndex:int = 0, endIndex:int = -1, options:Object = null ):IPathEngine
		{
			
			var dd:Number,ft1:Number,ft2:Number,ft3:Number,ft4:Number,fu1:Number,fu2:Number,fu3:Number,fu4:Number,
				fv1:Number,fv2:Number,fv3:Number,fv4:Number,fw1:Number,fw2:Number,fw3:Number,fw4:Number,
				fb:Number,ft:Number,fc:Number,ffa:Number,ffb:Number,ffc:Number,ffd:Number;
			
			var nStart:int; // Start at the first vector
			var nEnd:int; // End at next to last
			var nStep:int;  // Step one at a time
			var js:int;
			
			var data:Vector.<SamplePoint> = pathEngine.sampledPoints;
			var p:int = data.length;
			if ( endIndex == -1 ) endIndex = data.length-1;
			var result:IPathEngine = PathManager.getPathEngine(pathEngine.type);
			
			
			
			var paddedData:Vector.<SamplePoint> = data.slice( Math.max(0,startIndex - 1), Math.min( endIndex + 3, data.length ));
			if ( startIndex == 0 ) paddedData.unshift(paddedData[0].getClone());
			if ( endIndex == data.length - 1 ) paddedData.push(paddedData[paddedData.length-1].getClone());
			if ( endIndex >= data.length - 2) paddedData.push(paddedData[paddedData.length-1].getClone());
			
			
			
			// This section adds the extra data at the ends by repeating the end vectors.
			// Making these accessible would allow customizing the end behavior.
			//paddedData[1) = paddedData[2);  // Make the n-1 data for first X
			//paddedData[1) = paddedData[2);  // for Y
			
			// Look where your type starts & stops to see if you need to do this.
			//paddedData[p+1) = paddedData[p); // Make the n+1 for
			//paddedData[p+1) = paddedData[p); // the last vector
			//paddedData[p+2) = paddedData[p); // Make the n+2 for last vector
			//paddedData[p+2) = paddedData[p); // This is only necessary for some conditions.
			//You may want different start/stop points (nStart, nEnd) from what I have here..
			//
			// In this long section we select the desired basis matrix.
			
			//  CatMul Rom basis Matrix (hits every input vector)
			//
			// As t goes from 0 to 1 you go from n to n+1
			//          n-1      n   n+1   n+2
			//   t^3     -1     +3    -3    +1     /
			//   t^2     +2     -5     4    -1    /
			//   t^1     -1      0     1     0   /  2
			//   t^0      0      2     0     0  /
			
			dd=2;  //divisor    This allows the Basis matrix to be all integers.
			
			ft1=-1.0/dd; 
			ft2=3.0/dd; 
			ft3=-3.0/dd; 
			ft4=1/dd;
			
			fu1=2/dd; 
			fu2=-5/dd; 
			fu3=4/dd; 
			fu4=-1/dd;
			
			fv1=-1/dd; 
			fv2=0; 
			fv3=1/dd; 
			fv4=0;
			
			fw1=0; 
			fw2=2/dd;
			fw3=0; 
			fw4=0;
			
			nStart = 1; // Start at the first vector
			nEnd = p - 1; // End at next to last
			nStep=1;  // Step one at a time
			js=0;     // Interpolate from zero
				
			
			var useForwardDiff:Boolean = (options != null && options.useForwardDiff != null ? options.useForwardDiff : false); ;
			var interPts:int = (options != null && options.interpolationSteps != null ? options.interpolationSteps : 50);
			
			var delta:Number = (options != null && options.delta != null ? options.delta : useForwardDiff ? 1 / interPts : 0.5);;
			// Finally, this is where the rubber meets the road.
			// Derived from source code posted by Leon de Boer.
			//
			var delta2:Number = delta * delta;  // Pre-compute delta squared and cubed
			var delta3:Number = delta2 * delta; // These two lines for forward differences only.
			
			var fax:Number, fbx:Number, fcx:Number, fdx:Number, fay:Number, fby:Number, fcy:Number, fdy:Number;
			var n:int;
			
			
			var p1:SamplePoint,p2:SamplePoint,p3:SamplePoint,p4:SamplePoint;
			
			if ( !useForwardDiff )
			{
				
				//
				// Step through the vectors
				
				for ( n = nStart; n < nEnd; n += nStep )
				{
					p1 = paddedData[n-1];
					p2 = paddedData[n];
					p3 = paddedData[n+1];
					p4 = paddedData[n+2];
					//
					// These are the coefficients a, b, c, d, in  aT^3 + bT2 + cT + d
					// NOTE; All terms are here, so all types use same code.
					// To conserve calculations, terms with a zero in the basis matrix can be
					// removed.
					fax = ft1*p1.x + ft2*p2.x + ft3*p3.x + ft4*p4.x;
					fbx = fu1*p1.x + fu2*p2.x + fu3*p3.x + fu4*p4.x;
					fcx = fv1*p1.x + fv2*p2.x + fv3*p3.x + fv4*p4.x;
					fdx = fw1*p1.x + fw2*p2.x + fw3*p3.x + fw4*p4.x;
					//
					fay = ft1*p1.y + ft2*p2.y + ft3*p3.y + ft4*p4.y;
					fby = fu1*p1.y + fu2*p2.y + fu3*p3.y + fu4*p4.y;
					fcy = fv1*p1.y + fv2*p2.y + fv3*p3.y + fv4*p4.y;
					fdy = fw1*p1.y + fw2*p2.y + fw3*p3.y + fw4*p4.y;
					
					
					// For 3D you will have four more equations here for Z
					//
					// Calculate one segment of the interpolation here.
					// NOTE; For types which pass through the keys, j can stop at interPts
					// Then just pass the key through (and the first one].
					// WINDOW OUTPUT 2 Drawing window
					//
					
					
					
					// ================= Start of replacable section ===========================
					//
					var fx:Number = fdx; // The first point in the segment
					var fy:Number = fdy;
					//          And another for "Z"
					//
					//  Start drawing at the very first point
					if (  n == nStart ) 
					{ 
						result.addXY(fx,fy,-1,0,true);
						//g.moveTo(fx,fy);
					}
					//  Accent the beginning of eachsegment (knot)
					
					//     Note, My display is 0-255 high & wide & the origin is in the lower left.
					for ( var j:int = js+1;  j < interPts+1; j++ )
					{
						// Interpolate one segment
						var t:Number = j /interPts;        // The interpolation parameter steps from delta to
						// 1.
						// The simple polynomial evaluation first pre-computes t^2 & t^3
						//   T2 = t * t  T3 = T2 * t
						// Then the polynomials
						//   fx = fax*T3 + fbx*T2 + fcx*t + fdx
						//   fy = fay*T3 + fby*T2 + fcy*t + fdy
						//              And another for "Z"
						//
						// However, using Horner//s Rule saves calculations & time.
						fx = ((fax*t + fbx) * t + fcx) * t + fdx;  //interpolated x value (using Horner)
						fy = ((fay*t + fby) * t + fcy) * t + fdy;  //interpolated y value
						//              And another for "Z"
						// ================ End of replacable section =========================
						//
						
						//g.lineTo(fx,fy); 
						result.addXY(fx,fy,-1,0,true);
						
					}	 //  j   sub-step "between" vectors
					
					//  n   Move to the next vector set.
					//  Accent the very last point
					// Interpolation complete.  Back to Kansas
				} 
				
			}
			else 
			{
				for ( n = nStart; n < nEnd; n += nStep )
				{
					//
					// These are the coefficients a, b, c, d, in  aT^3 + bT2 + cT + d
					// NOTE; All terms are here, so all types use same code.
					// To conserve calculations, terms with a zero in the basis matrix can be
					// removed.
					p1 = paddedData[n-1];
					p2 = paddedData[n];
					p3 = paddedData[n+1];
					p4 = paddedData[n+2];
					
					fax = ft1*p1.x + ft2*p2.x + ft3*p3.x + ft4*p4.x;
					fbx = fu1*p1.x + fu2*p2.x + fu3*p3.x + fu4*p4.x;
					fcx = fv1*p1.x + fv2*p2.x + fv3*p3.x + fv4*p4.x;
					fdx = fw1*p1.x + fw2*p2.x + fw3*p3.x + fw4*p4.x;
					
					fay = ft1*p1.y + ft2*p2.y + ft3*p3.y + ft4*p4.y;
					fby = fu1*p1.y + fu2*p2.y + fu3*p3.y + fu4*p4.y;
					fcy = fv1*p1.y + fv2*p2.y + fv3*p3.y + fv4*p4.y;
					fdy = fw1*p1.y + fw2*p2.y + fw3*p3.y + fw4*p4.y;
					
					p1 = p2;
					p2 = p3;
					p3 = p4;
					
					//
					// ============== Forward Difference version  =====================
					//  This goes between the two === lines above.
					//  Derived from Foley, van Damm, Feiner & Hughes
					//  Forward Difference "derivatives" calculated here.
					//
					fx = fdx;  
					fy = fdy; // Initial position
					//              And another for "Z"
					//
					var fd1x:Number = fax*delta3+fbx*delta2+fcx*delta; // Initial velocity
					var fd1y:Number = fay*delta3+fby*delta2+fcy*delta;
					//              And another for "Z"
					//
					var fd2x:Number = 6*fax*delta3+2*fbx*delta2; // Initial acceleration
					var fd2y:Number = 6*fay*delta3+2*fby*delta2;
					//              And another for "Z"
					//
					var fd3x:Number = 6 * fax * delta3; // Acceleration change
					var fd3y:Number = 6 * fay * delta3;
					//              And another for "Z"
					//
					//  Start drawing at the very first point
					if (  n == nStart ) 
					{ 
						//g.moveTo(fx,fy);
						result.addXY(fx,fy,-1,0,true);
					}
					
					//
					for( j = js; j < interPts; j++ )
					{// Interpolate one segment
						fx = fx+fd1x;  //interpolated x value
						fy = fy+fd1y;  //interpolated y value
						//              And another for "Z"
						
						result.addXY(fx,fy,-1,0,true);
						//
						fd1x=fd1x+fd2x; 
						fd1y=fd1y+fd2y; // Next speed
						//              And another for "Z"
						
						fd2x=fd2x+fd3x;  
						fd2y=fd2y+fd3y;// Next acceleration
						//              And another for "Z"
						
						
					}
				}
			}
			
			return result;
		}
	}
}





