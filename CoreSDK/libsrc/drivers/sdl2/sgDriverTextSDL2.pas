unit sgDriverTextSDL2;

interface
	procedure LoadSDL2TextDriver();
		
implementation
	uses sgTypes, sgDriverSDL2Types, sgDriverText, sgShared;

	function LoadFontProcedure(fontName, fileName : String; size : Longint) : Font;
	var
		fdata: psg_font_data;
	begin
		New(result);
		New(fdata);
		if (result = nil) or (fdata = nil) then
		begin
			RaiseException('LoadFont to allocate space.');
			exit;
		end;

		fdata^ := _sg_functions^.text.load_font(PChar(fileName), size);
		result^.fptr := fdata;

		if result^.fptr = nil then
		begin
			Dispose(result);
			result := nil;
			RaiseWarning('LoadFont failed: ' + fontName + ' (' + fileName + ')');
			exit;
		end;

		result^.name := fontName;
	end;
	
	procedure CloseFontProcedure(fontToClose : Font);
	var
		fdata: psg_font_data;   
	begin
		fdata := fontToClose^.fptr;
		_sg_functions^.text.close_font(fdata);
		Dispose(fdata);
		fontToClose^.fptr := nil;
	end;
	
	//TODO: move most of this to sgText
	procedure PrintStringsProcedure(dest: Bitmap; font: Font; str: String; rc: Rectangle; clrFg, clrBg:Color; flags:FontAlignment);
	var
		clr: sg_color;
    	pts: array [0..4] of Single;
  	begin
		clr := _ToSGColor(clrBg);

		if clr.a > 0 then
		begin
			pts[0] := rc.x;
	    	pts[1] := rc.y;
    		pts[2] := rc.width;
    		pts[3] := rc.height;
			_sg_functions^.graphics.fill_aabb_rect(dest^.surface, clr, @pts[0], 4);
		end;
		_sg_functions^.text.draw_text(dest^.surface, font^.fptr, rc.x, rc.y, PChar(str), _ToSGColor(clrFg));
	end;
	
	procedure PrintWideStringsProcedure(dest: Bitmap; font: Font; str: WideString; rc: Rectangle; clrFg, clrBg:Color; flags:FontAlignment) ;
	begin
		WriteLn('PrintWideStringsProcedure!!!');
	end;
	
	procedure SetFontStyleProcedure(fontToSet : font; value : FontStyle);
	begin
		_sg_functions^.text.set_font_style(fontToSet^.fptr, Longint(value));
	end;
	
	function GetFontStyleProcedure(font : Font) : FontStyle;
	begin
		result := FontStyle(_sg_functions^.text.get_font_style(font^.fptr));
	end;
	
	function SizeOfTextProcedure(font : Font; theText : String; var w : Longint ; var h : Longint) : Integer;
	begin
		result := _sg_functions^.text.text_size(font^.fptr, PChar(theText), @w, @h);
	end;
	
	function SizeOfUnicodeProcedure(font : Font; theText : WideString; var w : Longint; var h : Longint) : Integer;
	begin
		result := 0;
	end;
	
	procedure QuitProcedure();
	begin
		//do nothing - now in general quit code
	end;
	
	function GetErrorProcedure() : String;
	begin
		result := 'TODO: ERRORS';
	end;
	
	function InitProcedure(): integer;
	begin
		// do nothing - now in standard startup
		result := 0;
	end;
	
	procedure StringColorProcedure(dest : Bitmap; x,y : Single; theText : String; theColor : Color); 
	begin
		_sg_functions^.text.draw_text(dest^.surface, nil, x, y, PChar(theText), _ToSGColor(theColor));
	end;

	function LineSkipFunction(fnt: Font): Integer;
	begin
		result := _sg_functions^.text.text_line_skip(fnt^.fptr);
	end;
	
//============================================================================= 
	
	procedure LoadSDL2TextDriver();
	begin
		TextDriver.LoadFont := @LoadFontProcedure;
		TextDriver.CloseFont := @CloseFontProcedure;
		TextDriver.PrintStrings := @PrintStringsProcedure;
		TextDriver.PrintWideStrings := @PrintWideStringsProcedure;
		TextDriver.SetFontStyle := @SetFontStyleProcedure;
		TextDriver.GetFontStyle := @GetFontStyleProcedure;
		TextDriver.SizeOfText := @SizeOfTextProcedure;
		TextDriver.SizeOfUnicode := @SizeOfUnicodeProcedure;
		TextDriver.Quit := @QuitProcedure;
		TextDriver.GetError := @GetErrorProcedure;
		TextDriver.Init := @InitProcedure;
		TextDriver.StringColor := @StringColorProcedure;

		TextDriver.LineSkip := @LineSkipFunction;
	end;

end.