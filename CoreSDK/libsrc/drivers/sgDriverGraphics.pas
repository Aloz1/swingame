unit sgDriverGraphics;
//=============================================================================
// sgDriverGraphics.pas
//=============================================================================
//
// The Graphics driver is responsible for acting as the interface between driver
// code and swingame code. Swingame code uses the graphics driver to access the 
// current active driver. 
//
// Changing this driver will probably cause graphics drivers to break.
//
// Notes:
//		- Pascal PChar is equivalent to a C-type string
// 		- Pascal Word is equivalent to a Uint16
//		- Pascal LongWord is equivalent to a Uint32
//		- Pascal SmallInt is equivalent to Sint16
//
//=============================================================================

interface
	uses sgTypes;
	
	type
	  GetPixel32Procedure                   = function (bmp: Bitmap; x, y: Single) : Color;
    FillTriangleProcedure                 = procedure (clr: Color; x1, y1, x2, y2, x3, y3: Single; const opts : DrawingOptions);  
    DrawTriangleProcedure                 = procedure (clr: Color; x1, y1, x2, y2, x3, y3: Single; const opts : DrawingOptions);      
    FillCircleProcedure                   = procedure (clr: Color; xc, yc, radius: Single; const opts : DrawingOptions); 
    DrawCircleProcedure                   = procedure (clr: Color; xc, yc, radius: Single; const opts : DrawingOptions);      
	  FillEllipseProcedure                  = procedure (clr: Color;  xPos, yPos, halfWidth, halfHeight: Single; const opts : DrawingOptions);
	  DrawEllipseProcedure                  = procedure (clr: Color;  xPos, yPos, halfWidth, halfHeight: Single; const opts : DrawingOptions);
		FillRectangleProcedure                = procedure (clr : Color; rect : Rectangle; const opts : DrawingOptions);
    DrawRectangleProcedure                = procedure (clr : Color; rect : Rectangle; const opts : DrawingOptions);
		DrawLineProcedure                     = procedure (clr : Color; x1, y1, x2, y2 : Single; const opts : DrawingOptions);
		DrawPixelProcedure                    = procedure (clr : Color; x, y : Single; const opts: DrawingOptions);
    SetClipRectangleProcedure             = procedure (dest : Bitmap; rect : Rectangle);      
    ResetClipProcedure                    = procedure (bmp: Bitmap);  
    SetVideoModeFullScreenProcedure       = procedure ();
    SetVideoModeNoFrameProcedure          = procedure ();      
    InitializeGraphicsWindowProcedure     = procedure (caption : String; screenWidth, screenHeight : LongInt);
    InitializeScreenProcedure             = procedure ( screen: Bitmap; width, height : LongInt; bgColor, stringColor : Color; msg : String);      
    ResizeGraphicsWindowProcedure         = procedure (newWidth, newHeight : LongInt);
    RefreshScreenProcedure                = procedure (screen : Bitmap);
    ColorComponentsProcedure              = procedure (c : Color; var r, g, b, a : Byte); 
    ColorFromProcedure                    = function  (bmp : Bitmap; r, g, b, a: Byte)  : Color;
    RGBAColorProcedure                    = function  (r, g, b, a: Byte)  : Color;
    // GetSurfaceWidthProcedure              = function  (src : Bitmap) : LongInt;
    // GetSurfaceHeightProcedure             = function  (src : Bitmap) : LongInt;
    GetScreenWidthProcedure               = function():LongInt;
    GetScreenHeightProcedure              = function():LongInt;
  	AvaialbleResolutionsProcedure         = function (): ResolutionArray;

	GraphicsDriverRecord = record
	  GetPixel32                : GetPixel32Procedure;
	  FillTriangle              : FillTriangleProcedure;
	  DrawTriangle              : DrawTriangleProcedure;	  
	  FillCircle                : FillCircleProcedure;
	  DrawCircle                : DrawCircleProcedure;	  
    FillEllipse               : FillEllipseProcedure;
	  DrawEllipse               : DrawEllipseProcedure;
	  FillRectangle             : FillRectangleProcedure;
		DrawLine                  : DrawLineProcedure;
		DrawPixel                 : DrawPixelProcedure;
    DrawRectangle             : DrawRectangleProcedure;
    SetClipRectangle          : SetClipRectangleProcedure;
    ResetClip                 : ResetClipProcedure;
    SetVideoModeFullScreen    : SetVideoModeFullScreenProcedure;
    SetVideoModeNoFrame       : SetVideoModeNoFrameProcedure;
    InitializeGraphicsWindow  : InitializeGraphicsWindowProcedure;
    InitializeScreen          : InitializeScreenProcedure;
    ResizeGraphicsWindow      : ResizeGraphicsWindowProcedure;
    RefreshScreen             : RefreshScreenProcedure;
    ColorComponents           : ColorComponentsProcedure;
    ColorFrom                 : ColorFromProcedure;
    RGBAColor                 : RGBAColorProcedure;
    GetScreenWidth            : GetScreenWidthProcedure;
    GetScreenHeight           : GetScreenHeightProcedure;
    AvailableResolutions      : AvaialbleResolutionsProcedure;
	end;
	
	var
		GraphicsDriver : GraphicsDriverRecord;
		
implementation
uses 
  {$IFDEF SWINGAME_SDL2}
    sgDriverGraphicsSDL2;
  {$ELSE}
    {$IFDEF SWINGAME_OPENGL}
      sgDriverGraphicsOpenGL;
    {$ELSE}
        {$IFDEF SWINGAME_SDL13}
          sgDriverGraphicsSDL13;
        {$ELSE}
          sgDriverGraphicsSDL;
        {$ENDIF}
    {$ENDIF}
  {$ENDIF}
    
	procedure LoadDefaultGraphicsDriver();
	begin
    {$IFDEF SWINGAME_SDL2}
      LoadSDL2GraphicsDriver();
    {$ELSE}
      {$IFDEF SWINGAME_OPENGL}
        {$INFO Using OpenGL Driver}
        LoadOpenGLGraphicsDriver();
      {$ELSE}
        {$IFDEF SWINGAME_SDL13}
          {$INFO Using SDL 2 Driver}
          LoadSDL13GraphicsDriver();  
        {$ELSE}
          {$INFO Using SDL 1.2 Driver}
          LoadSDLGraphicsDriver();
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
	end;
	
	function DefaultGetPixel32Procedure (bmp: Bitmap; x, y: Single) : Color;
	begin
		LoadDefaultGraphicsDriver();
		result := GraphicsDriver.GetPixel32(bmp, x, y);
	end;
	
  procedure DefaultFillTriangleProcedure(clr: Color; x1, y1, x2, y2, x3, y3: Single; const opts : DrawingOptions);
  begin
  	LoadDefaultGraphicsDriver();
  	GraphicsDriver.FillTriangle(clr, x1, y1, x2, y2, x3, y3, opts);
  end;

  procedure DefaultDrawTriangleProcedure(clr: Color; x1, y1, x2, y2, x3, y3: Single; const opts : DrawingOptions);
  begin
  	LoadDefaultGraphicsDriver();
  	GraphicsDriver.DrawTriangle(clr, x1, y1, x2, y2, x3, y3, opts);
  end;
  
  procedure DefaultFillCircleProcedure(clr: Color; xc, yc, radius: Single; const opts : DrawingOptions); 
  begin
  	LoadDefaultGraphicsDriver();
  	GraphicsDriver.FillCircle(clr, xc, yc, radius, opts);
  end;

  procedure DefaultDrawCircleProcedure(clr: Color; xc, yc, radius: Single; const opts : DrawingOptions); 
  begin
  	LoadDefaultGraphicsDriver();
  	GraphicsDriver.DrawCircle(clr, xc, yc, radius, opts);
  end;
	
	procedure DefaultFillEllipseProcedure (clr: Color; xPos, yPos, halfWidth, halfHeight: Single; const opts : DrawingOptions);
	begin
		LoadDefaultGraphicsDriver();
		GraphicsDriver.FillEllipse(clr,  xPos, yPos, halfWidth, halfHeight, opts);
	end;
	
	procedure DefaultDrawEllipseProcedure (clr: Color; xPos, yPos, halfWidth, halfHeight: Single; const opts: DrawingOptions);
	begin
		LoadDefaultGraphicsDriver();
		GraphicsDriver.DrawEllipse(clr,  xPos, yPos, halfWidth, halfHeight, opts);
	end;
	
	procedure DefaultFillRectangleProcedure (clr : Color; rect : Rectangle; const opts : DrawingOptions);
	begin
		LoadDefaultGraphicsDriver();
		GraphicsDriver.FillRectangle(clr, rect, opts);
	end;
	
	procedure DefaultDrawLineProcedure(clr : Color; x1, y1, x2, y2 : Single; const opts : DrawingOptions);
	begin
		LoadDefaultGraphicsDriver();
		GraphicsDriver.DrawLine(clr, x1, y1, x2, y2, opts);
	end;
	
	procedure DefaultDrawPixelProcedure(clr : Color; x, y : Single; const opts: DrawingOptions);
	begin
		LoadDefaultGraphicsDriver();
		GraphicsDriver.DrawPixel(clr, x, y, opts);
	end;
  
  procedure DefaultDrawRectangleProcedure (clr : Color; rect : Rectangle; const opts : DrawingOptions);
	begin
		LoadDefaultGraphicsDriver();
		GraphicsDriver.DrawRectangle(clr, rect, opts);
	end;
  
  procedure DefaultSetClipRectangleProcedure(dest : Bitmap; rect : Rectangle);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.SetClipRectangle(dest, rect);
  end;
  
  procedure DefaultResetClipProcedure(dest : Bitmap);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.ResetClip(dest);
  end;

  procedure DefaultSetVideoModeFullScreenProcedure();
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.SetVideoModeFullScreen();
  end;

  procedure DefaultSetVideoModeNoFrameProcedure();
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.SetVideoModeNoFrame();
  end;
	
  procedure DefaultInitializeGraphicsWindowProcedure(caption : String; screenWidth, screenHeight : LongInt);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.InitializeGraphicsWindow(caption, screenWidth, screenHeight);
  end;

  procedure DefaultInitializeScreenProcedure( screen: Bitmap; width, height : LongInt; bgColor, stringColor : Color; msg : String);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.InitializeScreen( screen, width, height, bgColor, stringColor, msg);
  end;
  
  procedure DefaultResizeGraphicsWindowProcedure(newWidth, newHeight : LongInt);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.ResizeGraphicsWindow(newWidth, newHeight);
  end;
    
  procedure DefaultRefreshScreenProcedure(screen : Bitmap);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.RefreshScreen(screen);
  end;
  
  procedure DefaultColorComponentsProcedure(c : Color; var r, g, b, a : Byte);
  begin
    LoadDefaultGraphicsDriver();
    GraphicsDriver.ColorComponents(c, r, g, b, a);
  end;
  
  function DefaultColorFromProcedure(bmp : Bitmap; r, g, b, a: Byte)  : Color;
  begin
    LoadDefaultGraphicsDriver();
    result := GraphicsDriver.ColorFrom(bmp, r, g, b, a);
  end;
  
  function DefaultRGBAColorProcedure(r, g, b, a: Byte)  : Color;
  begin
    LoadDefaultGraphicsDriver();
    result := GraphicsDriver.RGBAColor(r, g, b, a);
  end;

  // function DefaultGetSurfaceWidthProcedure(src : Bitmap)  : LongInt;
  // begin
  //   LoadDefaultGraphicsDriver();
  //   result := GraphicsDriver.GetSurfaceWidth(src);
  // end;

  // function DefaultGetSurfaceHeightProcedure(src : Bitmap)  : LongInt;
  // begin
  //   LoadDefaultGraphicsDriver();
  //   result := GraphicsDriver.GetSurfaceHeight(src);
  // end;
  
  function DefaultGetScreenWidthProcedure(): LongInt; 
  begin
    LoadDefaultGraphicsDriver();
    result := GraphicsDriver.GetScreenWidth();
  end;
  
  function DefaultGetScreenHeightProcedure(): LongInt; 
  begin
    LoadDefaultGraphicsDriver();
    result := GraphicsDriver.GetScreenHeight();
  end;

  function DefaultAvailableResolutionsProcedure(): ResolutionArray;
  begin
    LoadDefaultGraphicsDriver();
    result := GraphicsDriver.AvailableResolutions();
  end;

	initialization
	begin
		GraphicsDriver.GetPixel32               := @DefaultGetPixel32Procedure;
		GraphicsDriver.FillTriangle             := @DefaultFillTriangleProcedure;
		GraphicsDriver.DrawTriangle             := @DefaultDrawTriangleProcedure;		
		GraphicsDriver.FillCircle               := @DefaultFillCircleProcedure;
		GraphicsDriver.DrawCircle               := @DefaultDrawCircleProcedure;				
		GraphicsDriver.FillEllipse              := @DefaultFillEllipseProcedure;
		GraphicsDriver.DrawEllipse              := @DefaultDrawEllipseProcedure;
		GraphicsDriver.FillRectangle            := @DefaultFillRectangleProcedure;
		GraphicsDriver.DrawLine                 := @DefaultDrawLineProcedure;
		GraphicsDriver.DrawPixel                := @DefaultDrawPixelProcedure;
    GraphicsDriver.DrawRectangle            := @DefaultDrawRectangleProcedure;
    GraphicsDriver.SetClipRectangle         := @DefaultSetClipRectangleProcedure;
    GraphicsDriver.ResetClip                := @DefaultResetClipProcedure;
    GraphicsDriver.SetVideoModeFullScreen   := @DefaultSetVideoModeFullScreenProcedure;
    GraphicsDriver.SetVideoModeNoFrame      := @DefaultSetVideoModeNoFrameProcedure;
    GraphicsDriver.InitializeGraphicsWindow := @DefaultInitializeGraphicsWindowProcedure;
    GraphicsDriver.InitializeScreen         := @DefaultInitializeScreenProcedure;
    GraphicsDriver.ResizeGraphicsWindow     := @DefaultResizeGraphicsWindowProcedure;
    GraphicsDriver.RefreshScreen            := @DefaultRefreshScreenProcedure;
    GraphicsDriver.ColorComponents          := @DefaultColorComponentsProcedure;
    GraphicsDriver.ColorFrom                := @DefaultColorFromProcedure;
    GraphicsDriver.RGBAColor                := @DefaultRGBAColorProcedure;
    // GraphicsDriver.GetSurfaceWidth          := @DefaultGetSurfaceWidthProcedure;
    // GraphicsDriver.GetSurfaceHeight         := @DefaultGetSurfaceHeightProcedure;
    // GraphicsDriver.ToGfxColor               := @DefaultToGfxColorProcedure;
    GraphicsDriver.GetScreenWidth           := @DefaultGetScreenWidthProcedure;
    GraphicsDriver.GetScreenHeight          := @DefaultGetScreenHeightProcedure;
    GraphicsDriver.AvailableResolutions     := @DefaultAvailableResolutionsProcedure;
	end;
end.
	
	